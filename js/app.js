import { Atlas } from "./map.js";
import { buildLandMask, buildTerritories } from "./territory.js";

const SYSTEM_LABELS = {
  pinyin: ["Pinyin", "Liu Bei"],
  wadegiles: ["Wade–Giles", "Liu Pei"],
  yale: ["Yale", "Lyou Bei"],
  vietnamese: ["Vietnamese", "Lưu Bị"],
  korean: ["Korean", "유비"],
  japanese: ["Japanese", "Ryū Bi"],
};

const STORAGE_KEY = "threekingdoms.romanization";
const TOTAL_CHAPTERS = 120;

// factions.json ranks the Han court and the three kingdoms 0-3 and every transient
// warlord from 10 up. That boundary is what separates a faction that keeps its own
// legend heading from one that can be folded into "Others".
const MINOR_FACTION_RANK = 10;

const state = {
  corpus: null,
  atlas: null,
  chapter: 1,
  system: localStorage.getItem(STORAGE_KEY) || "pinyin",
  selection: null,   // { kind: "character" | "faction", id } or null
};

const $ = (sel) => document.querySelector(sel);

/* -------------------------------------------------------------------- naming */

/** Korean and Japanese are set in the CJK face; the four Latin systems are not. */
const isCJK = (system) => system === "korean";

function nameOf(entity) {
  return entity?.names?.[state.system] ?? entity?.name ?? "";
}

/** A name plus its hanzi, per the "romanization + hanzi always" rule. */
function nameNode(entity, { hanzi = true } = {}) {
  const frag = document.createDocumentFragment();
  const primary = document.createElement("span");
  primary.textContent = nameOf(entity);
  if (isCJK(state.system)) primary.className = "han";
  frag.append(primary);

  if (hanzi && entity.hanzi) {
    const han = document.createElement("span");
    han.className = "han";
    han.textContent = entity.hanzi;
    frag.append(han);
  }
  return frag;
}

/* ------------------------------------------------------------------ rendering */

function renderMap(chapter) {
  const { places, characters, factions } = state.corpus;
  const atlas = state.atlas;

  atlas.setTerritories(buildTerritories(chapter.control, places, factions), factions);
  atlas.clearMarkers();

  // -- places
  const shown = new Set(Object.values(chapter.control).flat());
  for (const pin of chapter.pins) {
    if (pin.at) shown.add(pin.at);
    if (pin.from) shown.add(pin.from);
  }
  // The dot and its name are separate markers so the name can hang below the city
  // while the character pins stack above it. As one element they fought each other.
  for (const id of shown) {
    const place = places[id];
    if (!place) continue;

    const dot = document.createElement("div");
    dot.className = `marker place-dot ${place.kind}`;
    atlas.addMarker([place.lon, place.lat], dot, { priority: 60 });

    const label = document.createElement("div");
    label.className = `marker place-label ${place.kind}`;
    label.append(nameNode(place));
    atlas.addMarker([place.lon, place.lat], label, {
      anchor: "top",
      offset: [0, 7],
      // Capitals keep their names even in a crowd; lesser towns yield to the pins.
      priority: place.kind === "capital" ? 40 : 10,
      hideable: true,
    });
  }

  // -- movement arcs, drawn before pins so the pins sit on top
  const moves = [];
  for (const pin of chapter.pins) {
    if (!pin.from || !pin.at || pin.from === pin.at) continue;
    const from = places[pin.from];
    const to = places[pin.at];
    if (!from || !to) continue;
    moves.push({
      from: [from.lon, from.lat],
      to: [to.lon, to.lat],
      color: characters[pin.character]?.color ?? "#888",
      character: pin.character,
    });
  }
  atlas.setPaths(moves);

  // -- character pins, fanned out where several share a city
  const byPlace = new Map();
  for (const pin of chapter.pins) {
    if (!pin.at) continue;
    if (!byPlace.has(pin.at)) byPlace.set(pin.at, []);
    byPlace.get(pin.at).push(pin);
  }

  for (const [placeId, pins] of byPlace) {
    const place = places[placeId];
    if (!place) continue;
    pins.forEach((pin, index) => {
      const character = characters[pin.character];
      if (!character) return;

      const el = document.createElement("div");
      el.className = "marker pin";
      el.style.color = character.color;
      el.dataset.character = pin.character;
      el.style.borderLeftColor = character.color;
      el.append(nameNode(character));

      el.addEventListener("click", () => select("character", pin.character));

      // Every pin starts just above its city dot; Atlas.relayout does all the
      // stacking, so pins sharing a city and pins at neighbouring cities are
      // separated by one mechanism instead of two that disagree.
      atlas.addMarker([place.lon, place.lat], el, {
        anchor: "bottom",
        offset: [0, -9],
        priority: 100 - index,
        leader: true,
      });
    });
  }

  atlas.relayout();
}

function legendHeading(text) {
  const h = document.createElement("h4");
  h.textContent = text;
  return h;
}

/**
 * Two sections: a key to the territory fills, then the chapter's cast grouped under
 * the faction they belong to.
 *
 * They are kept separate because the two lists barely overlap -- chapter 19 has
 * thirteen factions holding ground and characters from only three of them -- so one
 * merged list would be mostly headings with nothing under them.
 */
function renderLegend(chapter) {
  const { factions, characters } = state.corpus;
  const legend = $("#legend");
  legend.replaceChildren();

  // -- territory key
  const holding = Object.keys(chapter.control)
    .map((id) => factions[id])
    .filter(Boolean)
    .sort((a, b) => a.rank - b.rank);

  if (holding.length) {
    const section = document.createElement("div");
    section.className = "section";
    section.append(legendHeading("Territory"));

    const grid = document.createElement("div");
    grid.className = "swatches";
    for (const faction of holding) {
      const row = document.createElement("button");
      row.className = "row";
      row.dataset.faction = faction.id;
      row.title = `${faction.name} — click to isolate`;
      row.addEventListener("click", () => select("faction", faction.id));
      const swatch = document.createElement("span");
      swatch.className = "swatch";
      swatch.style.background = faction.fill;
      swatch.style.borderColor = faction.color;
      const label = document.createElement("span");
      label.className = "label";
      label.textContent = faction.short ?? faction.name;
      const han = document.createElement("span");
      han.className = "han";
      han.textContent = faction.hanzi;
      row.append(swatch, label, han);
      grid.append(row);
    }
    section.append(grid);
    legend.append(section);
  }

  // -- cast, grouped by faction, in the chapter's own pin order
  const groups = new Map();
  for (const pin of chapter.pins) {
    const character = characters[pin.character];
    if (!character) continue;
    if (!groups.has(character.faction)) groups.set(character.faction, []);
    groups.get(character.faction).push(character);
  }

  if (groups.size) {
    const section = document.createElement("div");
    section.className = "section";
    section.append(legendHeading("On the map"));

    const columns = document.createElement("div");
    columns.className = "cast-groups";

    // A warlord who is his own entire faction gets a heading that just repeats his
    // name -- "Tao Qian / Tao Qian" -- which is pure noise. Those collapse into one
    // shared group. The three kingdoms and the Han court never collapse however few
    // people they field, because burying Cao Cao under "Others" in a chapter where he
    // is the only Wei figure reads as a demotion rather than as tidying.
    const isMinor = (id) => (factions[id]?.rank ?? 99) >= MINOR_FACTION_RANK;
    const kept = [];
    const loose = [];
    for (const [factionId, members] of groups) {
      if (isMinor(factionId) && members.length === 1) loose.push(...members);
      else kept.push([factionId, members]);
    }
    kept.sort((a, b) => (factions[a[0]]?.rank ?? 99) - (factions[b[0]]?.rank ?? 99));

    const addMember = (group, character) => {
      const row = document.createElement("button");
      row.className = "member";
      row.dataset.character = character.id;
      row.style.borderLeftColor = character.color;
      row.append(nameNode(character));
      row.addEventListener("click", () => select("character", character.id));
      group.append(row);
    };

    for (const [factionId, members] of kept) {
      const faction = factions[factionId];
      const group = document.createElement("div");
      group.className = "group";

      const head = document.createElement("button");
      head.className = "group-head";
      head.dataset.faction = factionId;
      head.title = `${faction?.name ?? factionId} — click to isolate`;
      head.addEventListener("click", () => select("faction", factionId));
      const name = document.createElement("span");
      name.textContent = faction?.name ?? factionId;
      const han = document.createElement("span");
      han.className = "han";
      han.textContent = faction?.hanzi ?? "";
      head.append(name, han);
      group.append(head);

      for (const character of members) addMember(group, character);
      columns.append(group);
    }

    if (loose.length) {
      const group = document.createElement("div");
      group.className = "group";
      // Not a button: this bucket is several factions at once, so there is nothing
      // single for a click to isolate. The members inside are still selectable, and
      // each keeps its own faction colour, which is what identifies it.
      const head = document.createElement("div");
      head.className = "group-head loose";
      head.textContent = "Others";
      head.title = "Warlords fielding a single figure this chapter";
      group.append(head);
      for (const character of loose) addMember(group, character);
      columns.append(group);
    }
    section.append(columns);
    legend.append(section);
  }
}

function renderDetail(chapter) {
  const { characters, places } = state.corpus;
  const detail = $("#detail");
  detail.replaceChildren();

  const eyebrow = document.createElement("p");
  eyebrow.className = "eyebrow";
  eyebrow.textContent = `Chapter ${chapter.n}`;

  const title = document.createElement("h2");
  title.textContent = chapter.title;

  const year = document.createElement("p");
  year.className = "year";
  year.textContent = `${chapter.year} CE`;

  detail.append(eyebrow, title, year);

  for (const para of chapter.summary) {
    const p = document.createElement("p");
    p.className = "body";
    p.textContent = para;
    detail.append(p);
  }

  if (chapter.history) {
    const box = document.createElement("div");
    box.className = "history";
    const label = document.createElement("strong");
    label.textContent = "Against the record";
    box.append(label, document.createTextNode(chapter.history));
    detail.append(box);
  }

  const heading = document.createElement("h3");
  heading.textContent = "On the map";
  detail.append(heading);

  const list = document.createElement("ul");
  list.className = "cast";
  for (const pin of chapter.pins) {
    const character = characters[pin.character];
    if (!character) continue;

    const li = document.createElement("li");
    li.dataset.character = pin.character;

    const chip = document.createElement("span");
    chip.className = "chip";
    chip.style.background = character.color;

    const who = document.createElement("span");
    who.className = "who";
    who.append(nameNode(character));

    const where = document.createElement("span");
    where.className = "where";
    where.textContent = pin.at ? nameOf(places[pin.at]) : "";

    li.append(chip, who, where);
    li.addEventListener("click", () => select("character", pin.character));
    list.append(li);

    if (pin.note) {
      const note = document.createElement("li");
      note.className = "note";
      note.textContent = pin.note;
      list.append(note);
    }
  }
  detail.append(list);
}

/**
 * A selection is either one figure or one faction, never both, so that picking a
 * faction and picking a person are the same gesture with the same escape (click it
 * again). Everything downstream reads it through `litCharacters`.
 */
function litCharacters() {
  const sel = state.selection;
  if (!sel) return null; // nothing selected: everything lit
  if (sel.kind === "character") return [sel.id];
  return Object.values(state.corpus.characters)
    .filter((c) => c.faction === sel.id)
    .map((c) => c.id);
}

/** The faction the current selection implies — its own, or the selected figure's. */
function litFaction() {
  const sel = state.selection;
  if (!sel) return null;
  return sel.kind === "faction" ? sel.id : state.corpus.characters[sel.id]?.faction ?? null;
}

function applyEmphasis() {
  const lit = litCharacters();
  const litSet = lit && new Set(lit);
  const faction = litFaction();

  for (const el of document.querySelectorAll("[data-character]")) {
    el.classList.toggle("dimmed", Boolean(litSet) && !litSet.has(el.dataset.character));
  }
  for (const el of document.querySelectorAll("[data-faction]")) {
    el.classList.toggle("dimmed", Boolean(faction) && el.dataset.faction !== faction);
  }

  // Territory, arcs and leader lines are GL/SVG rather than DOM, so they are told
  // separately -- CSS cannot reach them.
  state.atlas?.setEmphasis({
    characters: lit,
    // Only a deliberate faction pick recolours the map; selecting one person should
    // not repaint every border on it.
    faction: state.selection?.kind === "faction" ? state.selection.id : null,
  });
}

function select(kind, id) {
  const sel = state.selection;
  state.selection = sel && sel.kind === kind && sel.id === id ? null : { kind, id };
  applyEmphasis();
}

/* ---------------------------------------------------------------- navigation */

function renderChapterList() {
  const list = $("#chapters");
  list.replaceChildren();
  const mapped = new Set(state.corpus.chapters.map((c) => c.n));

  for (let n = 1; n <= TOTAL_CHAPTERS; n++) {
    const chapter = state.corpus.chapters.find((c) => c.n === n);
    const li = document.createElement("li");
    li.dataset.n = String(n);
    if (!mapped.has(n)) li.className = "stub";

    const button = document.createElement("button");
    button.disabled = !mapped.has(n);

    const num = document.createElement("span");
    num.className = "num";
    num.textContent = String(n);

    const label = document.createElement("span");
    label.className = "label";
    label.textContent = chapter ? chapter.title : "—";
    if (chapter) button.title = chapter.title;

    button.append(num, label);
    button.addEventListener("click", () => show(n));
    li.append(button);
    list.append(li);
  }
}

function show(n) {
  const chapter = state.corpus.chapters.find((c) => c.n === n);
  if (!chapter) return;
  state.chapter = n;
  state.selection = null;

  for (const li of document.querySelectorAll("#chapters li")) {
    li.toggleAttribute("aria-current", Number(li.dataset.n) === n);
    if (Number(li.dataset.n) === n) li.setAttribute("aria-current", "true");
  }

  renderMap(chapter);
  renderLegend(chapter);
  renderDetail(chapter);
  applyEmphasis();
  if (chapter.focus) state.atlas.flyTo(chapter.focus);

  const mapped = state.corpus.chapters.map((c) => c.n);
  $("#pager-label").textContent = `Chapter ${n} of ${TOTAL_CHAPTERS}`;
  $("#prev").disabled = n <= Math.min(...mapped);
  $("#next").disabled = n >= Math.max(...mapped);
  $("#detail").scrollTop = 0;
  location.hash = `ch${n}`;
}

function step(delta) {
  const mapped = state.corpus.chapters.map((c) => c.n).sort((a, b) => a - b);
  const index = mapped.indexOf(state.chapter);
  const next = mapped[index + delta];
  if (next) show(next);
}

/* --------------------------------------------------------- romanization menu */

function renderRomanizationMenu() {
  const menu = $("#romanization-menu");
  menu.replaceChildren();

  for (const system of state.corpus.systems) {
    const [label, sample] = SYSTEM_LABELS[system] ?? [system, ""];
    const li = document.createElement("li");
    li.setAttribute("role", "none");
    li.setAttribute("aria-checked", String(system === state.system));

    const button = document.createElement("button");
    button.setAttribute("role", "menuitemradio");
    const name = document.createElement("span");
    name.textContent = label;
    const example = document.createElement("span");
    example.className = "sample" + (isCJK(system) ? " han" : "");
    example.textContent = sample;
    button.append(name, example);

    button.addEventListener("click", () => {
      state.system = system;
      localStorage.setItem(STORAGE_KEY, system);
      closeMenu();
      renderRomanizationMenu();
      show(state.chapter);
    });

    li.append(button);
    menu.append(li);
  }
  $("#romanization-current").textContent = SYSTEM_LABELS[state.system]?.[0] ?? state.system;
}

function closeMenu() {
  $("#romanization-menu").hidden = true;
  $("#romanization-toggle").setAttribute("aria-expanded", "false");
}

function wireMenu() {
  const toggle = $("#romanization-toggle");
  toggle.addEventListener("click", (event) => {
    event.stopPropagation();
    const menu = $("#romanization-menu");
    menu.hidden = !menu.hidden;
    toggle.setAttribute("aria-expanded", String(!menu.hidden));
  });
  document.addEventListener("click", closeMenu);
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeMenu();
    if (event.target.tagName === "INPUT") return;
    if (event.key === "ArrowLeft") step(-1);
    if (event.key === "ArrowRight") step(1);
  });
}

/* -------------------------------------------------------------------- start */

async function json(path) {
  const response = await fetch(path);
  if (!response.ok) throw new Error(`${path}: ${response.status} ${response.statusText}`);
  return response.json();
}

async function main() {
  const [corpus, land, landmask, rivers, lakes] = await Promise.all([
    json("data/corpus.json"),
    json("data/basemap/land.geojson"),
    json("data/basemap/landmask.geojson"),
    json("data/basemap/rivers.geojson"),
    json("data/basemap/lakes.geojson"),
  ]);

  state.corpus = corpus;
  // One pass over the coastline up front; every chapter's territory reuses the result.
  buildLandMask(landmask);

  state.atlas = new Atlas("map", { land, rivers, lakes });
  await state.atlas.ready;

  renderChapterList();
  renderRomanizationMenu();
  wireMenu();
  $("#prev").addEventListener("click", () => step(-1));
  $("#next").addEventListener("click", () => step(1));

  // Back/forward between chapters, and a shareable URL per chapter.
  window.addEventListener("hashchange", () => {
    const n = Number((location.hash.match(/^#ch(\d+)$/) || [])[1]);
    if (n && n !== state.chapter) show(n);
  });

  const fromHash = Number((location.hash.match(/^#ch(\d+)$/) || [])[1]);
  show(corpus.chapters.some((c) => c.n === fromHash) ? fromHash : 1);

  document.getElementById("app").classList.remove("loading");
}

main().catch((error) => {
  console.error(error);
  document.getElementById("splash").textContent = `Could not load: ${error.message}`;
});
