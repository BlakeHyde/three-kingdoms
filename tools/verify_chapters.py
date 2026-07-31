"""Check the atlas against the actual text of 三國演義.

    uv run tools/fetch_text.py        # once
    uv run tools/verify_chapters.py

The chapter data was written from knowledge of the novel rather than with the book
open, which is fine for the famous set-pieces and much less fine for the middle of the
Northern Expeditions. This checks what can be checked mechanically:

1. Every figure pinned in a chapter should be named somewhere in that chapter. Absence
   is strong evidence the pin is in the wrong chapter. (Presence is only weak evidence
   it is in the right one -- the text mentioning Cao Cao does not prove he was at
   Xuchang -- so this catches misplacement, not mislocation.)

2. Every place a chapter pins someone at should be named in that chapter. Weaker, since
   the novel often says "the camp" or "the pass", so this is reported separately and
   quietly.

The novel refers to people by courtesy name far more often than by given name -- Liu
Bei is 玄德 through most of the book and 劉備 only occasionally -- so matching uses the
full name, the courtesy name, the given name alone, and the common 姓+公 honorific.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEXT = ROOT / "data_cache" / "text"
CORPUS = ROOT / "web" / "data" / "corpus.json"

# Figures the novel names by title or epithet rather than by name.
ALIASES = {
    "emperorxian": ["獻帝", "劉協", "天子", "帝"],
    "liushan":     ["劉禪", "阿斗", "後主"],
    "caorui":      ["曹叡", "曹睿", "睿"],
    "zhurong":     ["祝融"],
    "sunshangxiang": ["孫夫人", "郡主"],
    "diaochan":    ["貂蟬", "貂蝉"],
}


def chapter_text(n: int) -> str:
    return (TEXT / f"ch{n:03d}.txt").read_text()


def canonical_title(raw: str) -> str | None:
    """Pull the couplet out of the {{Novel|...}} header."""
    # The separator between chapter number and couplet is an ideographic space in some
    # chapters and an ASCII one in others, and the numeral is spelled out rather than
    # padded the way the page title is.
    match = re.search(r"\{\{Novel\|三國演義\|第[^|]*?回[\s　]*'''(.+?)'''", raw)
    if not match:
        match = re.search(r"第[一二三四五六七八九十百零〇\d]+回[\s　]*'''(.+?)'''", raw)
    return re.sub(r"[\s　]+", " ", match.group(1)).strip() if match else None


def name_forms(character: dict) -> list[str]:
    forms = []
    if character.get("id") in ALIASES:
        forms += ALIASES[character["id"]]
    hanzi = character.get("hanzi") or ""
    surname = character.get("surname") or ""
    given = character.get("given") or ""
    if hanzi:
        forms.append(hanzi)
    courtesy = (character.get("courtesy") or {}).get("hanzi")
    if courtesy:
        forms.append(courtesy)
    if given and len(given) >= 2:
        forms.append(given)
    # 關公, 張將軍 and so on; the surname alone is too loose, but 姓+公 is not.
    if surname and len(surname) == 1:
        forms.append(surname + "公")
    return [f for f in dict.fromkeys(forms) if f]


def main() -> int:
    if not (TEXT / "ch001.txt").exists():
        print("no cached text; run tools/fetch_text.py first", file=sys.stderr)
        return 1

    corpus = json.loads(CORPUS.read_text())
    characters = corpus["characters"]
    places = corpus["places"]

    absent_people: list[str] = []
    absent_places: list[str] = []
    titles: dict[str, str] = {}

    for chapter in sorted(corpus["chapters"], key=lambda c: c["n"]):
        n = chapter["n"]
        raw = chapter_text(n)
        title = canonical_title(raw)
        if title:
            titles[str(n)] = title
        else:
            print(f"  ch{n}: could not parse canonical title", file=sys.stderr)

        body = re.sub(r"\{\{[^}]*\}\}", "", raw)   # strip templates, keep prose

        seen_places = set()
        for pin in chapter["pins"]:
            character = characters.get(pin["character"])
            if not character:
                continue
            if not any(form in body for form in name_forms(character)):
                absent_people.append(
                    f"ch{n:>3}: {character['names']['pinyin']} ({character['hanzi']}) "
                    f"is not named in the text"
                )
            if pin.get("at"):
                seen_places.add(pin["at"])

        for place_id in seen_places:
            place = places.get(place_id)
            if place and place["hanzi"] not in body:
                absent_places.append(
                    f"ch{n:>3}: {place['names']['pinyin']} ({place['hanzi']}) "
                    f"is not named in the text"
                )

    out = ROOT / "source" / "canonical_titles.json"
    out.write_text(json.dumps(titles, ensure_ascii=False, indent=2) + "\n")

    total_pins = sum(len(c["pins"]) for c in corpus["chapters"])
    print(f"  {len(titles)}/120 canonical titles extracted -> {out.relative_to(ROOT)}")
    print(f"  pins checked: {total_pins}")
    print(f"  figures pinned in a chapter that does not name them: {len(absent_people)}")
    for line in absent_people:
        print(f"    - {line}")
    print(f"  places pinned in a chapter that does not name them: {len(absent_places)}")
    for line in absent_places[:40]:
        print(f"    . {line}")
    if len(absent_places) > 40:
        print(f"    . ... and {len(absent_places) - 40} more")

    # Figures are a gate: if the chapter does not name them, the pin is wrong.
    # Places are advisory -- the novel frequently says "the camp" or "the pass", so
    # absence there means the location is inferred, not that it is mistaken.
    return 1 if absent_people else 0


if __name__ == "__main__":
    sys.exit(main())
