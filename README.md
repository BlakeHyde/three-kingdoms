# Three Kingdoms — an atlas

A chapter-by-chapter map of *Romance of the Three Kingdoms* (三國演義). Each chapter
shows the political situation as filled territory, pins the major figures where the
narrative puts them, and draws a dashed arc for anyone who moves during it — from the
peach garden oath to Du Yu's fleet coming down the Yangtze 96 years later.

Names can be read in **Pinyin, Wade–Giles, Yale, Vietnamese, Korean or Japanese**
(menu, upper right), always shown alongside the hanzi.

All 120 chapters are mapped.

```
uv run tools/clip_basemap.py     # once: fetch + clip coastline and rivers
uv run tools/build_relief.py     # once: bake the shaded-relief basemap image
uv run tools/build_elevation.py  # once: elevation grid for the terrain model
uv run tools/build_data.py       # compile source/ -> web/data/corpus.json
node tools/check_territory.mjs   # geometry regression check
uv run tools/fetch_text.py       # once: cache the Chinese text
uv run tools/build_versions.py   # once: normalise every edition per chapter
uv run tools/verify_chapters.py  # check the atlas against all of them
python3 -m http.server 8787 -d web
```

`build_relief.py` needs the Natural Earth raster in `data_cache/` first:

```
curl -sSL -o data_cache/NE2_HR_LC_SR_W.zip \
  https://naciscdn.org/naturalearth/10m/raster/NE2_HR_LC_SR_W.zip
unzip -o data_cache/NE2_HR_LC_SR_W.zip -d data_cache/relief
```

That download is ~310 MB and the cache can be deleted afterwards; the 700 KB image it
produces is what ships.

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

A chapter lists which places each faction holds. `web/js/territory.js` samples a grid
over the map and spreads control outward from each holding, spending a budget set by
that holding's `weight` — a provincial capital reaches much further than a mountain
pass. A cell goes to whichever faction reaches it most cheaply, and stays unclaimed if
nobody can afford it. Then the boundaries are traced and smoothed.

The spread is a least-cost search over terrain, not straight-line distance, because
straight lines get this period badly wrong: they run Liu Zhang's authority from Chengdu
over the Daliang Shan and deep into Yunnan, when that country was Meng Huo's precisely
because Chengdu could not hold it. Crossing a step costs its distance times

    1 + ELEVATION_TAX * (mean elevation, km) + SLOPE_TAX * gradient

so the Sichuan basin is nearly free and a range crossing costs several times its map
distance. Those two constants are tuning knobs, not measurements. A useful side effect
is that control cannot cross open sea, which is correct — Liaodong is reachable by the
coast road and not otherwise.

Elevation comes from `tools/build_elevation.py` as a 68 KB grid of uint16 decimetres at
exactly the sampling resolution; nothing finer would change the answer. The search is a
multi-source Dijkstra and runs in about 20 ms per chapter, which is faster than the
straight-line version it replaced.

This is why a chapter costs a list of city names rather than an afternoon in a vector
editor, and it is honest about a period where nobody knows where the borders were.

### The terrain is baked in, not tiled

Third-party topographic tiles would mean the map stops working offline, gains a
dependency that can rate-limit or vanish, and inherits someone else's attribution
terms. `tools/build_relief.py` instead crops Natural Earth's public-domain shaded
relief to the map window, warps it from equirectangular to Web Mercator (MapLibre maps
an `image` source linearly onto Mercator, so an unwarped image slides north as you go
up the map), mutes it so faction fills still read over it, and flattens the sea to one
colour. One 700 KB JPEG, no network.

Rivers are drawn from the 10m set rather than 50m, because the Wei, the Huai and the
Xiang are all missing at 50m and those are the three the campaigns turn on. Only the
courses named in `source/rivers.json` are kept — if a river is worth drawing here it is
worth labelling, and if it is not it is clutter. Labels use the name the text uses: the
Yangtze is 大江, the Yellow River is just 河.

Matching Natural Earth courses by name is fragile, so `clip_basemap.py` fails if one
river's segments fall into clusters far apart. That guard caught two rivers drawn in
the wrong country: Korea's Han (also called "Han") labelled 漢水, and Fujian's 閩江
(also romanized "Min") labelled 岷江. Names that need disambiguating carry a `within`
bounding box.

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

## Verification

The chapter data was written from knowledge of the novel rather than with the book open,
which is fine for the famous set-pieces and much less fine for the middle of the Northern
Expeditions. Checking it against one text tells you what that text says; checking it
against several tells you where the editions agree, and where they do not is where the
atlas is most likely to be wrong. Three editions, none encumbered:

| edition | | chapters |
|---|---|---|
| `wikisource_zh` | Chinese, Mao Zonggang recension | 1–120 |
| `gutenberg_zh` | Chinese, separate transcription (PG #23950) | 1–120 |
| `brewitt_en` | English, Brewitt-Taylor 1925 (PG #77416) | 1–60 |

Only volume one of the translation is public; the scans carrying volume two are OCR bad
enough to poison a vote. So chapters 61–120 are checked against two editions rather than
three, and the tool says so rather than papering over it.

**PRESENCE — every figure pinned in a chapter must be named in that chapter.** Each
edition votes; a pin no edition supports fails the build. A pin only some editions
support is reported, not enforced, since that usually means a romanization the matcher
does not know. This removed 27 pins and found three genuine errors: Cao Xiu's defeat and death
placed in ch. 98 when the text does not name him once (it is ch. 96), Zhuge Zhan placed in
ch. 116 when he dies at Mianzhu in ch. 117, and Zhang Jue held at Puyang in ch. 1–2, which those
chapters never name — the text puts him at 廣宗, besieged first by Lu Zhi and then by
Huangfu Song. (Puyang is emphatically in the novel; it is where Lü Bu and Cao Cao fight
over Yan province in ch. 11–12, and the atlas uses it correctly there. It simply has
nothing to do with Zhang Jue.)

**CONTINUITY — an atlas claims not just that someone was somewhere but that they got
there.** Each figure's pins are walked in chapter order as a path. A location change
between consecutive chapters with no `from` recorded is a movement the map silently
teleports and draws no arc for; there were 63 of those, and the graph knows where each
came from, so they are now filled in. That took the atlas from 152 movement arcs to 215.

Neither check can confirm a placement — the text naming Cao Cao does not prove he was at
Xuchang. Place names are reported but not enforced, because the novel frequently says
only "the camp"; about 110 pins sit somewhere the chapter does not name, and those are
inferences.

Each chapter also carries its canonical couplet, extracted from the same text and shown
under the translated title, so a reader can check the summary against a source rather than
taking it on trust. Where a translated title and the couplet diverge, believe the couplet.

**Still unverified:** the summaries themselves, and the "Against the record" notes. Those
are prose written from recollection, and nothing here checks them.

## Sources and accuracy

The map follows the **novel**, not the histories. Where they diverge materially the
chapter panel says so under *Against the record* — Guan Yu never met Hua Xiong, the
oath in the peach garden is not in the sources, Diaochan is an invention.

Basemap is [Natural Earth](https://www.naturalearthdata.com/) (public domain), clipped
to 92–132°E, 15–50°N. It is a **modern** basemap: the Han-era coastline differed around
the Bohai gulf, and Yunmeng Marsh — large enough to matter for the Jing province
campaigns — is drained and absent. Place coordinates are the modern location of the
Han-era site.
