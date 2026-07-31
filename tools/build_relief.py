"""Bake Natural Earth's shaded relief into a single muted basemap image.

    uv run tools/build_relief.py

Deliberately not a tile service. Third-party topographic tiles would mean the map
stops working offline, adds a dependency that can rate-limit or disappear, and drags
in someone else's attribution terms. Natural Earth II with shaded relief is public
domain, and the map window is small enough that the whole thing fits in one image.

Three things happen here:

1. A windowed read. The source is 21600x10800 and about 700 MB decoded, which will not
   fit in memory on a normal machine; ``tifffile.memmap`` pages in only the rows the
   crop touches.
2. A reprojection. The source is equirectangular and the map is Web Mercator. MapLibre
   maps an `image` source linearly onto Mercator space, so the image has to be warped
   here or the terrain slides north as you go up the map -- about fifteen km of error
   at the top of this window, which is visible against the coastline.
3. A mute. Faction fills are painted over this at partial opacity, so the relief is
   desaturated and lifted towards the paper colour until it reads as texture rather
   than as data competing with the territory.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

import numpy as np
import json

import tifffile
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "data_cache" / "relief" / "NE2_HR_LC_SR_W.tif"
OUT = ROOT / "web" / "data" / "basemap" / "relief.jpg"
LANDMASK = ROOT / "web" / "data" / "basemap" / "landmask.geojson"

# Must match WINDOW in clip_basemap.py and territory.js.
WEST, EAST, SOUTH, NORTH = 92.0, 132.0, 15.0, 50.0

PIXELS_PER_DEGREE = 60          # the 10m raster is 1/60 degree per pixel
DESATURATE = 0.38               # 0 = untouched, 1 = greyscale
LIFT_TO_PAPER = 0.22            # blend towards the page colour
PAPER = np.array([247, 244, 236], dtype=np.float32)
SEA = np.array([232, 238, 241], dtype=np.float32)   # matches the `sea` layer in map.js
JPEG_QUALITY = 82


def mercator_y(lat_deg: float) -> float:
    return math.log(math.tan(math.pi / 4 + math.radians(lat_deg) / 2))


def land_mask(width: int, height: int) -> np.ndarray:
    """Rasterise the dissolved coastline into the output grid, 1 on land, 0 at sea.

    Drawn at double resolution and downsampled, so the coast gets an antialiased edge
    instead of a staircase that fights the coastline stroke drawn over it.
    """
    scale = 2
    canvas = Image.new("L", (width * scale, height * scale), 0)
    draw = ImageDraw.Draw(canvas)

    y_north, y_south = mercator_y(NORTH), mercator_y(SOUTH)

    def project(lon: float, lat: float) -> tuple[float, float]:
        x = (lon - WEST) / (EAST - WEST) * width * scale
        lat = max(min(lat, 89.9), -89.9)
        y = (mercator_y(lat) - y_north) / (y_south - y_north) * height * scale
        return x, y

    geometry = json.loads(LANDMASK.read_text())["features"][0]["geometry"]
    polygons = (geometry["coordinates"] if geometry["type"] == "MultiPolygon"
                else [geometry["coordinates"]])
    for rings in polygons:
        for index, ring in enumerate(rings):
            points = [project(lon, lat) for lon, lat in ring]
            if len(points) > 2:
                # Ring 0 is the outline; the rest are inland water.
                draw.polygon(points, fill=255 if index == 0 else 0)

    canvas = canvas.resize((width, height), Image.LANCZOS)
    return np.asarray(canvas, dtype=np.float32) / 255.0


def main() -> int:
    if not SRC.exists():
        print(f"missing {SRC.relative_to(ROOT)}", file=sys.stderr)
        print("  curl -sSL -o data_cache/NE2_HR_LC_SR_W.zip \\", file=sys.stderr)
        print("    https://naciscdn.org/naturalearth/10m/raster/NE2_HR_LC_SR_W.zip", file=sys.stderr)
        print("  unzip -o data_cache/NE2_HR_LC_SR_W.zip -d data_cache/relief", file=sys.stderr)
        return 1

    raster = tifffile.memmap(SRC)               # (10800, 21600, 3), paged on access
    src_h, src_w = raster.shape[:2]

    x0 = round((WEST + 180.0) * PIXELS_PER_DEGREE)
    x1 = round((EAST + 180.0) * PIXELS_PER_DEGREE)
    y0 = round((90.0 - NORTH) * PIXELS_PER_DEGREE)
    y1 = round((90.0 - SOUTH) * PIXELS_PER_DEGREE)
    print(f"  source {src_w}x{src_h}; window x[{x0}:{x1}] y[{y0}:{y1}]")

    window = np.asarray(raster[y0:y1, x0:x1, :3], dtype=np.float32)
    win_h, win_w = window.shape[:2]

    # -- reproject rows from equirectangular to Mercator
    y_north, y_south = mercator_y(NORTH), mercator_y(SOUTH)
    aspect = (y_north - y_south) / math.radians(EAST - WEST)
    out_h = round(win_w * aspect)

    rows = np.arange(out_h, dtype=np.float64)
    merc = y_north + (y_south - y_north) * (rows + 0.5) / out_h
    lat = np.degrees(2.0 * np.arctan(np.exp(merc)) - math.pi / 2)
    src_row = (NORTH - lat) * PIXELS_PER_DEGREE
    src_row = np.clip(src_row, 0, win_h - 1.001)

    lower = np.floor(src_row).astype(np.int64)
    frac = (src_row - lower).astype(np.float32)[:, None, None]
    warped = window[lower] * (1.0 - frac) + window[lower + 1] * frac
    print(f"  warped {win_w}x{win_h} -> {win_w}x{out_h} (Mercator)")

    # -- mute
    lum = (warped * np.array([0.299, 0.587, 0.114], dtype=np.float32)).sum(axis=2, keepdims=True)
    muted = warped * (1.0 - DESATURATE) + lum * DESATURATE
    muted = muted * (1.0 - LIFT_TO_PAPER) + PAPER * LIFT_TO_PAPER

    # -- flatten the sea to one colour
    # Natural Earth's own ocean tint, once desaturated and lifted, comes out nearly
    # white and the coastline stops reading. Terrain is only meaningful on land here
    # anyway, so the sea is replaced with the flat colour the `sea` layer uses.
    mask = land_mask(win_w, out_h)[:, :, None]
    muted = muted * mask + SEA * (1.0 - mask)

    image = Image.fromarray(np.clip(muted, 0, 255).astype(np.uint8), mode="RGB")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(OUT, quality=JPEG_QUALITY, optimize=True, progressive=True)

    print(f"  -> {OUT.relative_to(ROOT)}  ({OUT.stat().st_size / 1024:.0f} KB)")
    print(f"  image corners: NW({WEST},{NORTH}) SE({EAST},{SOUTH})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
