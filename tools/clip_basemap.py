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

# Rivers come from the 10m set, not 50m: the Wei, the Huai and the Xiang are missing
# entirely at 50m, and those are the three the campaigns actually turn on. Rather than
# filter on rank, keep exactly the courses named in source/rivers.json -- if a river is
# worth drawing on this map it is worth labelling, and if it is not it is clutter.
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


def check_rivers_connected(features: list[dict], named: dict) -> None:
    """Fail if one river's courses fall into clusters far apart.

    Matching Natural Earth by name alone is fragile: 'Han' is both the Chinese 漢水 and
    the Korean river through Seoul, so the map briefly drew a watercourse near Seoul
    labelled 漢水. A river that is really one river is connected; two clusters a
    thousand km apart means the name matched something else.
    """
    problems = []
    for rid in named:
        geoms = [shape(f["geometry"]) for f in features if f["properties"]["river"] == rid]
        if not geoms:
            problems.append(f"{rid}: no courses matched {named[rid]['match']}")
            continue

        clusters: list = []
        for geom in geoms:
            merged = [geom]
            rest = []
            for cluster in clusters:
                (merged if cluster.distance(geom) < 0.4 else rest).append(cluster)
            clusters = rest + [unary_union(merged)]

        if len(clusters) > 1:
            spread = max(a.distance(b) for a in clusters for b in clusters)
            if spread > 2.0:
                boxes = "; ".join(str([round(v, 1) for v in c.bounds]) for c in clusters)
                problems.append(f"{rid}: {len(clusters)} disconnected clusters "
                                f"{spread:.1f} deg apart -- {boxes}")

    if problems:
        print("\n  river problems:", file=sys.stderr)
        for p in problems:
            print(f"    - {p}", file=sys.stderr)
        raise SystemExit(1)


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

    named = json.loads((ROOT / "source" / "rivers.json").read_text())["rivers"]
    wanted = {alias: rid for rid, r in named.items() for alias in r["match"]}

    def keep_river(props: dict) -> bool:
        rid = wanted.get(props.get("name") or props.get("name_en"))
        return rid is not None

    rivers = clip(fetch("ne_10m_rivers_lake_centerlines"), simplify=0.004, keep=keep_river)

    # Apply per-river bounding boxes for names Natural Earth reuses across the region.
    bounded = []
    for feature in rivers:
        props = feature["properties"]
        rid = wanted[props.get("name") or props.get("name_en")]
        limit = named[rid].get("within")
        if limit and not shape(feature["geometry"]).intersects(box(*limit)):
            continue
        bounded.append(feature)
    rivers = bounded
    # Tag each course with the river it belongs to, so the app can style by importance
    # and hang one label on a river made of several Natural Earth segments.
    for feature in rivers:
        props = feature["properties"]
        rid = wanted[props.get("name") or props.get("name_en")]
        feature["properties"] = {"river": rid, "rank": named[rid]["rank"]}
    check_rivers_connected(rivers, named)
    write("rivers", rivers)

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
