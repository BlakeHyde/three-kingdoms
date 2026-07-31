"""Fetch the Chinese text of 三國演義 from Wikisource, for verification.

    uv run tools/fetch_text.py

The novel is Ming-dynasty and long out of copyright; Wikisource carries the standard
Mao Zonggang recension. The text is cached under ``data_cache/text/`` and is never
shipped -- it exists so tools/verify_chapters.py can check the atlas against it.

Checking against the Chinese rather than a translation is deliberate: every character
and place in source/ carries its hanzi, so names can be matched exactly instead of
through the romanization, which is where errors would hide.
"""

from __future__ import annotations

import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "data_cache" / "text"

API = "https://zh.wikisource.org/w/api.php"
UA = "three-kingdoms-atlas/1.0 (research; https://github.com/BlakeHyde/three-kingdoms)"
PAUSE = 0.4          # be a polite client; 120 requests is nothing but no need to rush


def fetch(title: str) -> str:
    query = urllib.parse.urlencode({
        "action": "query", "prop": "revisions", "rvprop": "content",
        "rvslots": "main", "format": "json", "titles": title,
    })
    request = urllib.request.Request(f"{API}?{query}", headers={"User-Agent": UA})
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = json.load(response)
    page = next(iter(payload["query"]["pages"].values()))
    if "revisions" not in page:
        raise LookupError(f"no such page: {title}")
    return page["revisions"][0]["slots"]["main"]["*"]


def main() -> int:
    CACHE.mkdir(parents=True, exist_ok=True)
    fetched = 0

    for n in range(1, 121):
        path = CACHE / f"ch{n:03d}.txt"
        if path.exists():
            continue
        title = f"三國演義/第{n:03d}回"
        try:
            path.write_text(fetch(title))
        except (LookupError, urllib.error.HTTPError) as exc:
            print(f"  ch{n}: {exc}", file=sys.stderr)
            return 1
        fetched += 1
        if fetched % 20 == 0:
            print(f"  fetched {fetched} ...", flush=True)
        time.sleep(PAUSE)

    sizes = [len((CACHE / f"ch{n:03d}.txt").read_text()) for n in range(1, 121)]
    print(f"  {len(sizes)} chapters cached ({fetched} newly fetched)")
    print(f"  length: min {min(sizes)}, median {sorted(sizes)[60]}, max {max(sizes)} chars")
    return 0


if __name__ == "__main__":
    sys.exit(main())
