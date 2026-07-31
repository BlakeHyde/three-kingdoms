"""Build the elevation grid the territory model uses as terrain friction.

    uv run tools/build_elevation.py

Control in this period follows valleys and stops at ranges. A plain distance model
cannot express that: it happily runs Liu Zhang's authority from Chengdu straight over
the Daliang Shan and deep into Yunnan, which is exactly backwards -- that country was
Nanman territory precisely because Chengdu could not hold it.

So the territory field needs to know where the mountains are. Source is the public
terrain-tile mirror of SRTM/GMTED (elevation-tiles-prod), decoded from Mapzen's
"terrarium" encoding: elevation = R*256 + G + B/256 - 32768.

Output is deliberately tiny. The territory grid is 0.2 degrees, so nothing finer is
useful; the whole window is 200x175 samples, written as a 16-bit PNG in decimetres,
which is a few tens of KB rather than the hundreds of MB the source tiles occupy.

Written as a raw little-endian uint16 array rather than an image: a 16-bit PNG loses
precision going through a canvas, and the browser only ever wants the numbers.
"""

from __future__ import annotations

import io
import math
import sys
import urllib.error
import urllib.request
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "data_cache" / "terrain"
OUT = ROOT / "web" / "data" / "basemap" / "elevation.bin"

# Must match territory.js.
WEST, EAST, SOUTH, NORTH = 92.0, 132.0, 15.0, 50.0
GRID_STEP = 0.2
COLS = round((EAST - WEST) / GRID_STEP)
ROWS = round((NORTH - SOUTH) / GRID_STEP)

ZOOM = 5                      # ~1.2 km/px here: five times finer than the output grid
TILE = 256
SOURCE = "https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png"


def lon_to_tile(lon: float, zoom: int) -> float:
    return (lon + 180.0) / 360.0 * (1 << zoom)


def lat_to_tile(lat: float, zoom: int) -> float:
    rad = math.radians(lat)
    y = (1.0 - math.log(math.tan(rad) + 1.0 / math.cos(rad)) / math.pi) / 2.0
    return y * (1 << zoom)


def fetch_tile(z: int, x: int, y: int) -> np.ndarray:
    CACHE.mkdir(parents=True, exist_ok=True)
    path = CACHE / f"{z}_{x}_{y}.png"
    if not path.exists():
        url = SOURCE.format(z=z, x=x, y=y)
        try:
            with urllib.request.urlopen(url, timeout=60) as response:
                path.write_bytes(response.read())
        except urllib.error.HTTPError as exc:            # off the edge of the world
            if exc.code == 404:
                return np.zeros((TILE, TILE), dtype=np.float32)
            raise
    rgb = np.asarray(Image.open(io.BytesIO(path.read_bytes())).convert("RGB"), dtype=np.float32)
    return rgb[:, :, 0] * 256.0 + rgb[:, :, 1] + rgb[:, :, 2] / 256.0 - 32768.0


def main() -> int:
    x0, x1 = math.floor(lon_to_tile(WEST, ZOOM)), math.ceil(lon_to_tile(EAST, ZOOM))
    y0, y1 = math.floor(lat_to_tile(NORTH, ZOOM)), math.ceil(lat_to_tile(SOUTH, ZOOM))
    print(f"  tiles z{ZOOM} x[{x0}:{x1}] y[{y0}:{y1}] = {(x1 - x0) * (y1 - y0)} tiles")

    mosaic = np.zeros(((y1 - y0) * TILE, (x1 - x0) * TILE), dtype=np.float32)
    for ty in range(y0, y1):
        for tx in range(x0, x1):
            mosaic[(ty - y0) * TILE:(ty - y0 + 1) * TILE,
                   (tx - x0) * TILE:(tx - x0 + 1) * TILE] = fetch_tile(ZOOM, tx, ty)

    # Sample the mosaic at each territory-grid cell centre. The grid is in plain
    # lon/lat while the mosaic is Mercator, so latitude has to go through the
    # projection rather than being scaled linearly.
    grid = np.zeros((ROWS, COLS), dtype=np.float32)
    for j in range(ROWS):
        lat = SOUTH + (j + 0.5) * GRID_STEP
        py = (lat_to_tile(lat, ZOOM) - y0) * TILE
        for i in range(COLS):
            lon = WEST + (i + 0.5) * GRID_STEP
            px = (lon_to_tile(lon, ZOOM) - x0) * TILE
            # Average a small window so a single peak does not stand for a whole cell.
            y_lo, y_hi = int(max(py - 3, 0)), int(min(py + 4, mosaic.shape[0]))
            x_lo, x_hi = int(max(px - 3, 0)), int(min(px + 4, mosaic.shape[1]))
            grid[j, i] = mosaic[y_lo:y_hi, x_lo:x_hi].mean()

    # Row 0 is the SOUTH edge, matching territory.js cell indexing.
    land = grid[grid > 0]
    print(f"  land elevation: median {np.median(land):.0f} m, "
          f"95th {np.percentile(land, 95):.0f} m, max {grid.max():.0f} m")

    # Decimetres in uint16, clamped at sea level: nothing below the waterline matters
    # to an army, and it keeps the encoding a straight unsigned scale. Row 0 is SOUTH.
    decimetres = np.clip(grid, 0, 6553.5) * 10.0
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(decimetres.astype("<u2").tobytes())

    print(f"  -> {OUT.relative_to(ROOT)}  ({COLS}x{ROWS} uint16 decimetres, "
          f"{OUT.stat().st_size / 1024:.0f} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
