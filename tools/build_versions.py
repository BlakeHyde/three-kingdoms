"""Normalise several editions of the novel into one per-chapter shape.

    uv run tools/build_versions.py

Verifying against a single text tells you what that text says. Verifying against several
tells you what the novel says, and -- more usefully -- shows you where the editions
disagree, which is exactly where the atlas is most likely to be wrong.

Three editions, none of them encumbered:

  wikisource_zh  Chinese, the Mao Zonggang recension, from zh.wikisource.org
  gutenberg_zh   Chinese, a separate transcription (Project Gutenberg #23950)
  brewitt_en     English, C.H. Brewitt-Taylor's 1925 translation (Gutenberg #77416)

The English is volume one only, so it covers chapters 1-60. Gutenberg does not carry
volume two and the scans that do are raw OCR bad enough to poison a vote, so chapters
61-120 are checked against two editions rather than three. That asymmetry is real and
tools/verify_chapters.py reports it rather than papering over it.

Output: data_cache/versions/<edition>/ch###.txt
"""

from __future__ import annotations

import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "data_cache"
VERSIONS = CACHE / "versions"

CHAPTERS = 120


def strip_gutenberg(text: str) -> str:
    """Drop the Project Gutenberg header and licence footer."""
    start = re.search(r"\*\*\*\s*START OF TH[EIS]+ PROJECT GUTENBERG EBOOK.*?\*\*\*", text, re.S)
    end = re.search(r"\*\*\*\s*END OF TH[EIS]+ PROJECT GUTENBERG EBOOK", text)
    return text[(start.end() if start else 0):(end.start() if end else len(text))]


def write(edition: str, chunks: dict[int, str]) -> None:
    out = VERSIONS / edition
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    for n, body in chunks.items():
        (out / f"ch{n:03d}.txt").write_text(body.strip() + "\n")
    lengths = sorted(len(v) for v in chunks.values())
    print(f"  {edition:<14} {len(chunks):>3} chapters   "
          f"median {lengths[len(lengths) // 2]:>6,} chars")


def split_on(text: str, pattern: str, expected: int, label: str) -> dict[int, str]:
    """Cut a whole-book text at chapter headings, numbering them in document order.

    Numbering by position rather than by parsing the heading is deliberate: these
    editions write chapter numbers in at least three different numeral systems
    (第一回, 第一○六回, CHAPTER LVII) and getting the sequence from the document is
    both simpler and harder to get subtly wrong.
    """
    marks = list(re.finditer(pattern, text))
    if len(marks) != expected:
        raise SystemExit(f"{label}: found {len(marks)} chapter marks, expected {expected}")
    chunks = {}
    for i, mark in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(text)
        chunks[i + 1] = text[mark.start():end]
    return chunks


def main() -> int:
    VERSIONS.mkdir(parents=True, exist_ok=True)

    # -- Wikisource: already one file per chapter, just strip wiki templates
    source = CACHE / "text"
    if not (source / "ch001.txt").exists():
        print("run tools/fetch_text.py first", file=sys.stderr)
        return 1
    wiki = {}
    for n in range(1, CHAPTERS + 1):
        raw = (source / f"ch{n:03d}.txt").read_text()
        wiki[n] = re.sub(r"\{\{[^}]*\}\}", "", raw)
    write("wikisource_zh", wiki)

    # -- Gutenberg Chinese. Zero is written ○ (white circle), not 〇.
    zh_path = VERSIONS / "gutenberg_23950.txt"
    if zh_path.exists():
        zh = strip_gutenberg(zh_path.read_text(errors="replace"))
        write("gutenberg_zh", split_on(zh, r"第[一二三四五六七八九十百零〇○\d]{1,6}回[：:]",
                                       CHAPTERS, "gutenberg_zh"))
    else:
        print(f"  missing {zh_path.relative_to(ROOT)}", file=sys.stderr)

    # -- Brewitt-Taylor English, volume one: chapters 1-60
    en_path = VERSIONS / "gutenberg_77416.txt"
    if en_path.exists():
        en = strip_gutenberg(en_path.read_text(errors="replace"))
        write("brewitt_en", split_on(en, r"CHAPTER\s+[IVXLC]+\.", 60, "brewitt_en"))
    else:
        print(f"  missing {en_path.relative_to(ROOT)}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
