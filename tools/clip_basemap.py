"""Clip Natural Earth vectors to the Three Kingdoms map window.

Natural Earth is public domain. Source files are cached in ``data_cache/`` on first
run; the clipped GeoJSON is written into ``web/data/basemap/`` where the app loads it
directly (no tile server, so the site stays a plain static folder).

    uv run tools/clip_basemap.py

Resolution note: 10m is used for land because the coastline is the most-looked-at line
on the map, 50m for rivers and lakes where 10m adds bulk without adding legibility at
the zooms this app uses.
"""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

from shapely.geometry import box, mapping, shape
from shapely.ops import unary_union

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "data_cache"
OUT = ROOT / "web" / "data" / "basemap"

BASE = "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson"

# Han-era oikoumene plus the frontiers that matter to the novel: Liaodong and the
# Korean commanderies in the northeast, Nanzhong and Jiaozhi in the south, the
# Hexi corridor and Qiang country in the west.
WINDOW = box(92.0, 15.0, 132.0, 50.0)

# Natural Earth's 50m layers carry scalerank rather than the length_km/sqkm columns
# the 10m ones have, so importance is filtered on rank. Rank 8 is generous on purpose:
# tributaries the campaigns turn on (the Wei, the Han, the Ru) rank well below the
# Yangtze but decide where armies can actually cross.
MAX_RIVER_RANK = 8
MAX_LAKE_RANK = 3


def fetch(name: str) -> dict:
    path = CACHE / f"{name}.geojson"
    if not path.exists():
        CACHE.mkdir(parents=True, exist_ok=True)
        url = f"{BASE}/{name}.geojson"
        print(f"  downloading {name} ...", flush=True)
        urllib.request.urlretrieve(url, path)
    return json.loads(path.read_text())


def write(name: str, features: list[dict]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.geojson"
    path.write_text(
        json.dumps({"type": "FeatureCollection", "features": features}, separators=(",", ":"))
    )
    kb = path.stat().st_size / 1024
    print(f"  {name:<12} {len(features):>5} features  {kb:>8.0f} KB")


def rank(props: dict, limit: int) -> bool:
    """Natural Earth's most important features are scalerank 0, so `or 99` defaulting
    silently drops every one of them. Compare against None explicitly."""
    r = props.get("scalerank")
    return r is not None and r <= limit


def clip(fc: dict, simplify: float = 0.0, keep=lambda props: True) -> list[dict]:
    out = []
    for feat in fc["features"]:
        if not keep(feat.get("properties") or {}):
            continue
        geom = shape(feat["geometry"])
        if not geom.is_valid:
            geom = geom.buffer(0)
        if not geom.intersects(WINDOW):
            continue
        geom = geom.intersection(WINDOW)
        if simplify:
            geom = geom.simplify(simplify, preserve_topology=True)
        if geom.is_empty:
            continue
        out.append({"type": "Feature", "properties": feat.get("properties") or {},
                    "geometry": mapping(geom)})
    return out


def strip_props(features: list[dict], keys: tuple[str, ...]) -> list[dict]:
    """Natural Earth carries ~60 columns per feature; we render with almost none."""
    for f in features:
        p = f["properties"]
        f["properties"] = {k: p[k] for k in keys if p.get(k) not in (None, "")}
    return features


def main() -> int:
    print("Clipping Natural Earth to the map window ...")

    land = clip(fetch("ne_10m_land"), simplify=0.004)
    land = strip_props(land, ())
    write("land", land)

    # One dissolved land polygon, heavily simplified. The app uses this purely as a
    # point-in-polygon mask so the territory field never bleeds into the sea, and at
    # that job a coarse outline is indistinguishable from a fine one but far faster.
    merged = unary_union([shape(f["geometry"]) for f in land]).simplify(0.02)
    write("landmask", [{"type": "Feature", "properties": {}, "geometry": mapping(merged)}])

    rivers = clip(
        fetch("ne_50m_rivers_lake_centerlines"),
        simplify=0.005,
        keep=lambda p: rank(p, MAX_RIVER_RANK),
    )
    write("rivers", strip_props(rivers, ("name", "name_en")))

    lakes = clip(
        fetch("ne_50m_lakes"),
        simplify=0.005,
        keep=lambda p: rank(p, MAX_LAKE_RANK),
    )
    write("lakes", strip_props(lakes, ("name", "name_en", "name_zht")))

    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
