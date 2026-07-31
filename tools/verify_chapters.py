"""Check the atlas against several editions of the novel, and against itself.

    uv run tools/fetch_text.py       # once
    uv run tools/build_versions.py   # once
    uv run tools/verify_chapters.py

The chapter data was written from knowledge of the novel rather than with the book open.
Checking it against one text tells you what that text says; checking it against three
tells you where the editions agree, and where they do not is exactly where the atlas is
most likely to be wrong.

Two independent checks:

PRESENCE. Every figure pinned in a chapter should be named in that chapter. Each edition
votes. A pin no edition supports is an error and fails the build. A pin only some
editions support is reported as a disagreement -- usually that means the figure is there
under a name the matcher does not know, occasionally that the editions differ.

CONTINUITY. An atlas claims not just that someone was somewhere but that they got there,
so the pins for each figure are walked in chapter order as a path:

  - if a figure's location changes between appearances, the later pin should record
    `from`, or the map silently teleports them and draws no movement arc
  - a recorded `from` should match where they were actually last seen
  - a journey should be physically possible in the chapters available for it

None of this can confirm a placement -- the text naming Cao Cao does not prove he was at
Xuchang. It catches what is checkable: figures in the wrong chapter, and paths that do
not join up.
"""

from __future__ import annotations

import json
import math
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERSIONS = ROOT / "data_cache" / "versions"
WIKI = ROOT / "data_cache" / "text"
CORPUS = ROOT / "web" / "data" / "corpus.json"

CHINESE = {"wikisource_zh", "gutenberg_zh"}

# Figures the novel names by title or epithet rather than by name.
ALIASES_ZH = {
    "emperorxian": ["獻帝", "劉協", "天子"],
    "liushan": ["劉禪", "阿斗", "後主"],
    "caorui": ["曹叡", "曹睿"],
    "zhurong": ["祝融"],
    "sunshangxiang": ["孫夫人", "郡主"],
}
ALIASES_EN = {
    "emperorxian": ["emperor hsien", "hsien ti", "the emperor"],
    "liushan": ["liu shan", "a tou", "ah tou"],
    "sunshangxiang": ["lady sun"],
    "zhugeliang": ["chuko liang", "kung ming"],
    "diaochan": ["tiao chan", "diao chan"],
}

# A journey longer than this between consecutive chapters, with no `from` recorded,
# is worth a second look.
SUSPICIOUS_KM = 700.0


def normalise_en(text: str) -> str:
    """Fold the punctuation the translation and the atlas spell differently.

    Brewitt-Taylor writes Tsʻao Tsʻao with a modifier letter and Chuko Liang unhyphenated;
    the atlas writes Ts'ao Ts'ao and Chu-ko Liang. Neither is wrong, so both are flattened.
    """
    text = unicodedata.normalize("NFC", text.casefold())
    text = re.sub(r"[‘’ʻʼʾʿ'`´\-]", "", text)
    return re.sub(r"\s+", " ", text)


def squash(text: str) -> str:
    """Word breaks removed as well, so Kung-ming, Kung ming and Kungming all agree."""
    return text.replace(" ", "")


def forms_zh(character: dict) -> list[str]:
    forms = list(ALIASES_ZH.get(character["id"], []))
    if character.get("hanzi"):
        forms.append(character["hanzi"])
    courtesy = (character.get("courtesy") or {}).get("hanzi")
    if courtesy:
        forms.append(courtesy)
    given = character.get("given") or ""
    if len(given) >= 2:
        forms.append(given)
    surname = character.get("surname") or ""
    if len(surname) == 1:
        forms.append(surname + "公")
    return [f for f in dict.fromkeys(forms) if f]


def forms_en(character: dict) -> list[str]:
    forms = list(ALIASES_EN.get(character["id"], []))
    for system in ("wadegiles", "pinyin"):
        name = character["names"].get(system)
        if name:
            forms.append(name)
    return [normalise_en(f) for f in dict.fromkeys(forms) if f]


def haversine(a: dict, b: dict) -> float:
    lat1, lat2 = math.radians(a["lat"]), math.radians(b["lat"])
    dlat = lat2 - lat1
    dlon = math.radians(b["lon"] - a["lon"])
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    return 2 * 6371.0 * math.asin(math.sqrt(h))


def canonical_title(raw: str) -> str | None:
    match = re.search(r"\{\{Novel\|三國演義\|第[^|]*?回[\s　]*'''(.+?)'''", raw)
    if not match:
        match = re.search(r"第[一二三四五六七八九十百零〇\d]+回[\s　]*'''(.+?)'''", raw)
    return re.sub(r"[\s　]+", " ", match.group(1)).strip() if match else None


def load_editions() -> dict[str, dict[int, str]]:
    editions: dict[str, dict[int, str]] = {}
    for directory in sorted(VERSIONS.iterdir()):
        if not directory.is_dir():
            continue
        chunks = {}
        for path in sorted(directory.glob("ch*.txt")):
            raw = path.read_text(errors="replace")
            chunks[int(path.stem[2:])] = raw if directory.name in CHINESE else normalise_en(raw)
        if chunks:
            editions[directory.name] = chunks
    return editions


def main() -> int:
    editions = load_editions()
    if not editions:
        print("no editions; run tools/build_versions.py first", file=sys.stderr)
        return 1

    corpus = json.loads(CORPUS.read_text())
    characters = corpus["characters"]
    places = corpus["places"]
    chapters = sorted(corpus["chapters"], key=lambda c: c["n"])

    print("  editions:")
    for name, chunks in editions.items():
        print(f"    {name:<15} chapters {min(chunks)}-{max(chunks)}")

    # -- canonical titles, from the Wikisource copy that carries the headers
    titles = {}
    for n in range(1, 121):
        path = WIKI / f"ch{n:03d}.txt"
        if path.exists():
            title = canonical_title(path.read_text())
            if title:
                titles[str(n)] = title
    if len(titles) == 120:
        (ROOT / "source" / "canonical_titles.json").write_text(
            json.dumps(titles, ensure_ascii=False, indent=2) + "\n"
        )

    unsupported: list[str] = []
    disputed: list[str] = []

    for chapter in chapters:
        n = chapter["n"]
        covering = [name for name, chunks in editions.items() if n in chunks]
        for pin in chapter["pins"]:
            character = characters.get(pin["character"])
            if not character:
                continue
            votes = []
            for name in covering:
                body = editions[name][n]
                if name in CHINESE:
                    hit = any(f in body for f in forms_zh(character))
                else:
                    forms = forms_en(character)
                    hit = any(f in body for f in forms) or \
                          any(squash(f) in squash(body) for f in forms)
                if hit:
                    votes.append(name)
            label = f"ch{n:>3} {character['names']['pinyin']} ({character['hanzi']})"
            if not votes:
                unsupported.append(f"{label}: named by no edition")
            elif len(votes) < len(covering):
                missing = ", ".join(sorted(set(covering) - set(votes)))
                disputed.append(f"{label}: absent from {missing}")

    # -- continuity
    journeys: dict[str, list[tuple[int, str, str | None]]] = {}
    for chapter in chapters:
        for pin in chapter["pins"]:
            if pin.get("at"):
                journeys.setdefault(pin["character"], []).append(
                    (chapter["n"], pin["at"], pin.get("from"))
                )

    teleports: list[str] = []
    bad_from: list[str] = []
    implausible: list[str] = []

    for cid, steps in journeys.items():
        name = characters[cid]["names"]["pinyin"]
        for (prev_n, prev_at, _), (n, at, origin) in zip(steps, steps[1:]):
            if at == prev_at:
                continue
            here, there = places[prev_at], places[at]
            if origin is None and n - prev_n == 1:
                teleports.append(
                    f"{name}: ch{prev_n} {here['names']['pinyin']} -> "
                    f"ch{n} {there['names']['pinyin']}"
                )
            elif origin is not None and origin != prev_at:
                bad_from.append(
                    f"{name}: ch{n} says from {places[origin]['names']['pinyin']}, "
                    f"but ch{prev_n} had them at {here['names']['pinyin']}"
                )
            distance = haversine(here, there)
            if distance > SUSPICIOUS_KM and n - prev_n <= 1:
                implausible.append(
                    f"{name}: {distance:.0f} km, {here['names']['pinyin']} -> "
                    f"{there['names']['pinyin']}, ch{prev_n} to ch{n}"
                )

    def section(title: str, rows: list[str], limit: int = 20) -> None:
        print(f"\n  {title}: {len(rows)}")
        for row in rows[:limit]:
            print(f"    - {row}")
        if len(rows) > limit:
            print(f"    ... and {len(rows) - limit} more")

    section("pins no edition supports", unsupported)
    section("pins some editions do not name", disputed)
    section("consecutive-chapter moves with no `from` (missing movement arc)", teleports)
    # Advisory only: a `from` naming somewhere the figure was never pinned is usually
    # correct -- they moved offstage in a chapter they do not appear in.
    section("`from` not matching the last pinned location (often legitimate)", bad_from, limit=8)
    section("journeys worth a second look", implausible)

    # Only an unsupported pin is an error. The rest are advisories: a `from` naming
    # somewhere the figure was never pinned usually means they moved during a chapter
    # they do not appear in, which is normal.
    return 1 if unsupported else 0


if __name__ == "__main__":
    sys.exit(main())
