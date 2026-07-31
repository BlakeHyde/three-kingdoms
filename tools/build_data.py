"""Compile source/ into the JSON the web app loads.

    uv run tools/build_data.py

Does three things the browser should not have to:

1. Composes every name in six conventions from the per-hanzi reading table.
2. Derives each character's colour from their faction's hue via an OKLCH ramp, so
   colours stay in family without anyone hand-picking two hundred hex codes.
3. Validates. Unknown hanzi, duplicate shade indices, chapters referring to places or
   characters that do not exist, and out-of-window coordinates all fail the build
   rather than turning into a blank pin at zero-zero.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from romanize import UnknownSyllable, capitalize, convert, detone

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "source"
OUT = ROOT / "web" / "data"

SYSTEMS = ["pinyin", "wadegiles", "yale", "vietnamese", "korean", "japanese"]

# Reading table column order (see source/readings.json).
PY, VI, KO, JA, KO_INIT = 0, 1, 2, 3, 4

errors: list[str] = []


def fail(msg: str) -> None:
    errors.append(msg)


def load(name: str) -> dict:
    data = json.loads((SRC / name).read_text())
    return {k: v for k, v in data.items() if not k.startswith("_")}


# --------------------------------------------------------------------------- names


def compose(hanzi: str, readings: dict, where: str, initial: bool) -> dict[str, str] | None:
    """Build one word (a surname, a given name, a placename) in all six conventions.

    `initial` marks the word as starting a name, which is what triggers the Korean
    initial-sound rule.
    """
    syllables = []
    for i, char in enumerate(hanzi):
        entry = readings.get(char)
        if entry is None:
            fail(f"{where}: no reading for {char!r} (in {hanzi!r}); add it to source/readings.json")
            return None
        syllables.append((char, entry, initial and i == 0))

    out: dict[str, str] = {}

    # Pinyin keeps the umlaut but drops tones, which is how these names are written in
    # English-language editions: Lü Bu, not Lǚ Bù. An apostrophe goes in wherever the
    # next syllable opens with a vowel, or Chang'an reads as Chan-gan.
    bare = [detone(e[PY]) for _, e, _ in syllables]
    joined = bare[0]
    for syllable in bare[1:]:
        joined += ("'" if syllable[0] in "aeo" else "") + syllable
    out["pinyin"] = capitalize(joined)

    for system in ("wadegiles", "yale"):
        try:
            parts = [convert(e[PY], system) for _, e, _ in syllables]
        except UnknownSyllable as exc:
            fail(f"{where}: {exc}")
            return None
        # Wade-Giles hyphenates polysyllabic given names (Chu-ko, Ssu-ma); Yale runs
        # them together.
        joiner = "-" if system == "wadegiles" else ""
        out[system] = capitalize(joiner.join(parts))

    out["vietnamese"] = " ".join(e[VI] for _, e, _ in syllables)
    out["korean"] = "".join(
        (e[KO_INIT] if is_init and len(e) > KO_INIT else e[KO]) for _, e, is_init in syllables
    )
    # Japanese on'yomi run together as one word: 諸葛 -> Shokatsu, not Sho Katsu. The
    # table stores each reading capitalised, so all but the first need lowering.
    ja = "".join(e[JA] for _, e, _ in syllables)
    out["japanese"] = ja[:1].upper() + ja[1:].lower()

    return out


def name_for(entry: dict, readings: dict, where: str) -> dict:
    """Full display name per system, with any overrides applied last."""
    surname = entry.get("surname", "")
    given = entry.get("given", "")

    parts_s = compose(surname, readings, where, initial=True) if surname else None
    parts_g = compose(given, readings, where, initial=not surname) if given else None

    override = entry.get("override") or {}
    if "pinyin" in override:
        # An explicit syllable list replaces the table lookup for every derived system.
        syllables = override["pinyin"]
        if len(syllables) != len(surname + given):
            fail(f"{where}: pinyin override has {len(syllables)} syllables for "
                 f"{len(surname + given)} hanzi")
        else:
            try:
                parts_g = {
                    "pinyin": capitalize("".join(detone(s) for s in syllables)),
                    "wadegiles": capitalize("-".join(convert(s, "wadegiles") for s in syllables)),
                    "yale": capitalize("".join(convert(s, "yale") for s in syllables)),
                }
            except UnknownSyllable as exc:
                fail(f"{where}: {exc}")
                return dict.fromkeys(SYSTEMS, surname + given)
            parts_s = None
            # The override only redirects the Sinitic readings; Vietnamese, Korean and
            # Japanese still come from the per-hanzi table unless separately overridden.
            table = compose(surname + given, readings, where, initial=True)
            for k in ("vietnamese", "korean", "japanese"):
                parts_g[k] = (table or {}).get(k, "")

    names: dict[str, str] = {}
    for system in SYSTEMS:
        chunks = [p[system] for p in (parts_s, parts_g) if p]
        if system == "korean":
            # Korean writes personal names solid: 유비, not 유 비.
            names[system] = "".join(chunks)
        else:
            names[system] = " ".join(chunks)
        if system in override and isinstance(override[system], str):
            names[system] = override[system]

    return names


# ---------------------------------------------------------------------- oklch colour


def oklch_to_hex(L: float, C: float, H_deg: float) -> str:
    """OKLCH -> sRGB hex, gamut-clipped.

    Ramping lightness in OKLCH (rather than HSL) is what keeps a faction's darkest and
    lightest members recognisably the same colour instead of drifting muddy.
    """
    import math

    h = math.radians(H_deg)
    a, b = C * math.cos(h), C * math.sin(h)

    l_ = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m_ = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s_ = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3

    r = +4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_
    g = -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_
    bl = -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_

    def encode(c: float) -> int:
        c = max(0.0, min(1.0, c))
        srgb = 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055
        return max(0, min(255, round(srgb * 255)))

    return "#{:02x}{:02x}{:02x}".format(encode(r), encode(g), encode(bl))


# Lightness steps ordered so consecutive shade indices land far apart. Assigning 0,1,2
# in lightness order would make the first three members of a faction -- usually its most
# important three -- the hardest to tell apart.
LIGHTNESS = [0.42, 0.60, 0.32, 0.52, 0.68, 0.37, 0.64, 0.47]
CHROMA_SCALE = [1.0, 0.82, 1.12, 0.70, 0.94, 1.18]


def shade_color(hue: float, chroma: float, index: int) -> str:
    L = LIGHTNESS[index % len(LIGHTNESS)]
    C = chroma * CHROMA_SCALE[index % len(CHROMA_SCALE)]
    # Fan the hue within a narrow wedge so members stay unmistakably same-family.
    hue_shift = ((index * 137.508) % 40.0) - 20.0
    return oklch_to_hex(L, C, hue + hue_shift)


# --------------------------------------------------------------------------- pipeline


def main() -> int:
    readings = load("readings.json")
    factions = load("factions.json")["factions"]
    characters = load("characters.json")["characters"]
    places = load("places.json")["places"]
    rivers = load("rivers.json")["rivers"]
    # Extracted from the Wikisource text by tools/verify_chapters.py. Carried into the
    # corpus so every chapter shows the couplet it is meant to be summarising -- a
    # reader can check the summary against a source rather than taking it on trust.
    titles_path = SRC / "canonical_titles.json"
    canonical = json.loads(titles_path.read_text()) if titles_path.exists() else {}

    # -- factions
    for fid, f in factions.items():
        f["id"] = fid
        f["color"] = oklch_to_hex(0.46, f["chroma"], f["hue"])
        f["fill"] = oklch_to_hex(0.74, f["chroma"] * 0.9, f["hue"])
        f["names"] = {s: f["name"] for s in SYSTEMS}

    # -- characters
    used_shades: dict[str, dict[int, str]] = {}
    for cid, c in characters.items():
        where = f"characters.{cid}"
        c["id"] = cid
        fid = c.get("faction")
        if fid not in factions:
            fail(f"{where}: unknown faction {fid!r}")
            continue
        c["names"] = name_for(c, readings, where)
        c["hanzi"] = c.get("surname", "") + c.get("given", "")

        shade = c.get("shade", 0)
        clash = used_shades.setdefault(fid, {}).get(shade)
        if clash:
            fail(f"{where}: shade {shade} already used by {clash} in faction {fid}")
        used_shades[fid][shade] = cid
        c["color"] = shade_color(factions[fid]["hue"], factions[fid]["chroma"], shade)

    # -- places
    for pid, p in places.items():
        where = f"places.{pid}"
        p["id"] = pid
        p["names"] = name_for({"given": p["hanzi"], "override": p.get("override")},
                              readings, where)
        if not (92.0 <= p["lon"] <= 132.0 and 15.0 <= p["lat"] <= 50.0):
            fail(f"{where}: ({p['lon']}, {p['lat']}) is outside the map window")

    # -- rivers
    for rid, r in rivers.items():
        r["id"] = rid
        r["names"] = name_for({"given": r["hanzi"]}, readings, f"rivers.{rid}")
        lon, lat = r["at"]
        if not (92.0 <= lon <= 132.0 and 15.0 <= lat <= 50.0):
            fail(f"rivers.{rid}: label anchor ({lon}, {lat}) is outside the map window")

    # -- chapters
    chapters = []
    for path in sorted((SRC / "chapters").glob("ch*.json")):
        ch = json.loads(path.read_text())
        where = f"chapters/{path.name}"
        for pid in ch.get("control", {}):
            if pid not in factions:
                fail(f"{where}: control names unknown faction {pid!r}")
        # A place may be held by exactly one faction in a chapter. Two claims on the
        # same city make the territory field pick a winner by iteration order, which
        # silently produces a different map depending on dict ordering.
        claimed: dict[str, str] = {}
        for pid, sites in ch.get("control", {}).items():
            seen: set[str] = set()
            for site in sites:
                if site not in places:
                    fail(f"{where}: control[{pid}] names unknown place {site!r}")
                    continue
                if site in seen:
                    fail(f"{where}: control[{pid}] lists {site!r} twice")
                seen.add(site)
                if site in claimed and claimed[site] != pid:
                    fail(f"{where}: {site!r} is claimed by both {claimed[site]!r} and {pid!r}")
                claimed[site] = pid
        for pin in ch.get("pins", []):
            if pin["character"] not in characters:
                fail(f"{where}: pin names unknown character {pin['character']!r}")
            if pin.get("at") and pin["at"] not in places:
                fail(f"{where}: pin names unknown place {pin['at']!r}")
            if pin.get("from") and pin["from"] not in places:
                fail(f"{where}: move names unknown origin {pin['from']!r}")
        ch["canonicalTitle"] = canonical.get(str(ch["n"]))
        if not ch["canonicalTitle"]:
            fail(f"{where}: no canonical title; run tools/verify_chapters.py")
        chapters.append(ch)

    if errors:
        print(f"\n{len(errors)} problem(s):\n", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    bundle = {
        "systems": SYSTEMS,
        "factions": factions,
        "characters": characters,
        "places": places,
        "rivers": rivers,
        "chapters": chapters,
    }
    path = OUT / "corpus.json"
    path.write_text(json.dumps(bundle, ensure_ascii=False, separators=(",", ":")))

    print(f"  {len(factions)} factions, {len(characters)} characters, "
          f"{len(places)} places, {len(rivers)} rivers, {len(chapters)} chapters")
    print(f"  -> {path.relative_to(ROOT)}  ({path.stat().st_size / 1024:.0f} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
