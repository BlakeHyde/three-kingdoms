# Three Kingdoms — an atlas

A chapter-by-chapter map of *Romance of the Three Kingdoms* (三國演義). Each chapter
shows the political situation as filled territory, pins the major figures where the
narrative puts them, and draws a dashed arc for anyone who moves during it.

Names can be read in **Pinyin, Wade–Giles, Yale, Vietnamese, Korean or Japanese**
(menu, upper right), always shown alongside the hanzi.

Chapters 1–20 are mapped. 21–120 are listed but empty — see *Adding a chapter*.

```
uv run tools/clip_basemap.py     # once: fetch + clip the basemap
uv run tools/build_data.py       # compile source/ -> web/data/corpus.json
python3 -m http.server 8787 -d web
```

Then open <http://localhost:8787/>. It is a static folder: no server-side code, no
network access at runtime, no API keys. `#ch14` in the URL jumps to a chapter.

## How it fits together

```
source/          hand-authored data — the only files you edit
  readings.json    per-hanzi readings; every name is composed from this
  factions.json    factions, colours, notes
  characters.json  the cast
  places.json      gazetteer
  chapters/        one file per chapter
tools/           python build; fails loudly rather than emitting bad data
web/             the site; open index.html through a web server
  data/            build output — generated, do not edit
```

### Names are composed, not typed

`source/readings.json` holds one row per hanzi. Every name in all six conventions is
assembled from it, so adding a figure in chapter 60 usually costs no new data at all —
the characters in their name are already there. Wade–Giles and Yale are derived from
the pinyin by `tools/romanize.py`, which is a lookup table rather than a rule engine
on purpose: a table cannot be subtly wrong, and an unknown syllable fails the build
instead of silently producing plausible nonsense.

Irregular readings go in an `override`. 會稽 is the standard example — 會 is normally
*huì*, but here it is *kuài*, and Vietnamese wants *Cối* rather than *Hội*.

### Colours come from the faction

Characters get a `shade` index, not a hex code. The build walks an OKLCH ramp around
their faction's hue, so Liu Bei, Guan Yu and Zhao Yun are three distinguishable blues
that are obviously the same blue family. Duplicate shades within a faction fail the
build.

Allegiance is **proleptic**: Cao Cao carries Wei red in chapter 1, decades before Wei
exists. It means mild foreshadowing, but a character's colour never changes under you.

### Territory is derived, not drawn

A chapter lists which places each faction holds. `web/js/territory.js` samples a grid,
assigns each land cell to whichever faction's nearest holding is closest — scaled by
that holding's `weight`, so a provincial capital outranks a village — leaves cells
beyond everyone's reach unclaimed, then traces and smooths the boundaries.

This is why a chapter costs a list of city names rather than an afternoon in a vector
editor, and it is honest about a period where nobody knows where the borders were.

### Labels are DOM, not GL

The MapLibre style has no glyph server, so GL layers draw fills and lines only. Every
label is an HTML marker, which also lets one label set a serif romanization beside a
sans-serif hanzi run. `Atlas.relayout()` in `web/js/map.js` does a greedy screen-space
declutter after every move, searching outward in both axes so eleven flags around
Luoyang stay beside their cities instead of forming one tall column.

## Adding a chapter

Copy an existing file in `source/chapters/`:

```jsonc
{
  "n": 21,
  "title": "...",
  "year": "199",
  "summary": ["one paragraph per entry"],
  "history": "where the novel departs from the record",
  "control": { "wei": ["xuchang", "luoyang"], "yuanshao": ["ye"] },
  "pins": [
    { "character": "caocao", "at": "xuchang", "from": "xiapi", "note": "..." }
  ],
  "focus": { "lon": 114, "lat": 34.5, "zoom": 5 }
}
```

`from` is optional and draws the movement arc. Run `uv run tools/build_data.py`; it
will name any character, place or faction that does not exist, any coordinate outside
the map window, and any hanzi missing from the reading table.

## Sources and accuracy

The map follows the **novel**, not the histories. Where they diverge materially the
chapter panel says so under *Against the record* — Guan Yu never met Hua Xiong, the
oath in the peach garden is not in the sources, Diaochan is an invention.

Basemap is [Natural Earth](https://www.naturalearthdata.com/) (public domain), clipped
to 92–132°E, 15–50°N. It is a **modern** basemap: the Han-era coastline differed around
the Bohai gulf, and Yunmeng Marsh — large enough to matter for the Jing province
campaigns — is drained and absent. Place coordinates are the modern location of the
Han-era site.
