/*
 * MapLibre setup and per-chapter rendering.
 *
 * Everything is local: the style has no sprite and no glyphs URL, and every source is a
 * GeoJSON file on disk. That means GL layers can draw fills and lines but not text, so
 * all labels are DOM markers instead (see makeMarker). The trade is a good one here --
 * a DOM label can put a serif romanization and a sans-serif hanzi run in the same line,
 * which one GL glyph stack could not.
 */

const EMPTY = { type: "FeatureCollection", features: [] };

export class Atlas {
  constructor(container, basemap) {
    this.markers = [];
    this.layout = [];
    this.lit = null; // set of character ids that stay lit, or null for all

    this.map = new maplibregl.Map({
      container,
      style: {
        version: 8,
        sources: {
          land: { type: "geojson", data: basemap.land },
          lakes: { type: "geojson", data: basemap.lakes },
          rivers: { type: "geojson", data: basemap.rivers },
          territory: { type: "geojson", data: EMPTY },
          paths: { type: "geojson", data: EMPTY },
        },
        layers: [
          { id: "sea", type: "background", paint: { "background-color": "#e8eef1" } },
          {
            id: "land", type: "fill", source: "land",
            paint: { "fill-color": "#fbf9f3" },
          },
          {
            id: "territory-fill", type: "fill", source: "territory",
            paint: { "fill-color": ["get", "fill"], "fill-opacity": 0.62 },
          },
          {
            id: "territory-edge", type: "line", source: "territory",
            paint: {
              "line-color": ["get", "color"],
              "line-width": 1.1,
              "line-opacity": 0.5,
            },
          },
          {
            id: "coast", type: "line", source: "land",
            paint: { "line-color": "#b9c6cc", "line-width": 0.8 },
          },
          {
            id: "lakes", type: "fill", source: "lakes",
            paint: { "fill-color": "#dde9ee", "fill-outline-color": "#c3d3da" },
          },
          {
            id: "rivers", type: "line", source: "rivers",
            paint: {
              "line-color": "#c2d4dc",
              "line-width": ["interpolate", ["linear"], ["zoom"], 3, 0.5, 7, 2.2],
            },
          },
          {
            id: "paths", type: "line", source: "paths",
            paint: {
              "line-color": ["get", "color"],
              "line-width": 1.8,
              "line-opacity": 0.85,
              "line-dasharray": [2.5, 2],
            },
          },
        ],
      },
      center: [114, 34],
      zoom: 4.4,
      minZoom: 3,
      maxZoom: 9,
      attributionControl: { customAttribution: "Basemap: Natural Earth (public domain)" },
    });

    // Decluttering can push a pin a long way from its city, so each one keeps a hairline
    // back to its dot. Drawn as one SVG overlay rather than a GL layer because the
    // endpoints live in screen space, not on the map.
    this.leaders = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    this.leaders.setAttribute("class", "leaders");
    this.map.getContainer().appendChild(this.leaders);

    this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }), "top-left");
    this.ready = new Promise((resolve) => this.map.on("load", resolve));

    // Decluttering depends on projected pixel positions, so it has to rerun as the
    // map moves -- coalesced to one pass per frame.
    let queued = false;
    this.map.on("move", () => {
      if (queued) return;
      queued = true;
      requestAnimationFrame(() => { queued = false; this.relayout(); });
    });
  }

  /** Territory polygons carry their own colours so one layer can paint every faction. */
  setTerritories(collection, factions) {
    for (const feature of collection.features) {
      const faction = factions[feature.properties.faction];
      feature.properties.fill = faction?.fill ?? "#dddddd";
      feature.properties.color = faction?.color ?? "#999999";
    }
    this.map.getSource("territory").setData(collection);
  }

  /**
   * Movement is drawn as a shallow arc rather than a straight line: two characters
   * travelling between the same pair of cities in opposite directions would otherwise
   * be one line, and an arc also reads as "roughly this way" rather than as a surveyed
   * route, which is all the novel supports.
   */
  setPaths(moves) {
    const features = moves.map(({ from, to, color, character }) => {
      const points = [];
      const [x0, y0] = from;
      const [x1, y1] = to;
      const bulge = 0.16;
      const cx = (x0 + x1) / 2 - (y1 - y0) * bulge;
      const cy = (y0 + y1) / 2 + (x1 - x0) * bulge;
      const STEPS = 28;
      for (let s = 0; s <= STEPS; s++) {
        const t = s / STEPS;
        const u = 1 - t;
        points.push([
          u * u * x0 + 2 * u * t * cx + t * t * x1,
          u * u * y0 + 2 * u * t * cy + t * t * y1,
        ]);
      }
      return {
        type: "Feature",
        properties: { color, character },
        geometry: { type: "LineString", coordinates: points },
      };
    });
    this.map.getSource("paths").setData({ type: "FeatureCollection", features });
  }

  /**
   * Fade everything the current selection excludes.
   *
   * `characters` is the list that stays lit (null = all), `faction` the territory that
   * stays lit (null = all). These are separate because selecting a person should fade
   * the other people without repainting every border on the map, while selecting a
   * faction should do both.
   */
  setEmphasis({ characters = null, faction = null } = {}) {
    this.lit = characters ? new Set(characters) : null;

    if (this.map.getLayer("paths")) {
      this.map.setPaintProperty(
        "paths",
        "line-opacity",
        characters
          ? ["case", ["in", ["get", "character"], ["literal", characters]], 0.95, 0.08]
          : 0.85
      );
    }
    if (this.map.getLayer("territory-fill")) {
      this.map.setPaintProperty(
        "territory-fill",
        "fill-opacity",
        faction ? ["case", ["==", ["get", "faction"], faction], 0.78, 0.1] : 0.62
      );
      this.map.setPaintProperty(
        "territory-edge",
        "line-opacity",
        faction ? ["case", ["==", ["get", "faction"], faction], 0.9, 0.12] : 0.5
      );
      this.map.setPaintProperty(
        "territory-edge",
        "line-width",
        faction ? ["case", ["==", ["get", "faction"], faction], 2.2, 1.1] : 1.1
      );
    }
    this.drawLeaders();
  }

  clearMarkers() {
    for (const marker of this.markers) marker.remove();
    this.markers = [];
    this.layout = [];
  }

  /**
   * `anchor` must do the positioning, not CSS. Marker writes its own inline transform
   * on the element every frame, so any `transform` in a stylesheet is overwritten and
   * the element ends up centred on the point regardless of what the CSS asked for.
   *
   * `priority` decides who wins a collision (higher survives); `hideable` marks labels
   * that may be dropped outright rather than pushed around forever.
   */
  addMarker(lngLat, element, opts = {}) {
    const {
      anchor = "center", offset = [0, 0], priority = 0, hideable = false, leader = false,
    } = opts;
    const marker = new maplibregl.Marker({ element, anchor, offset })
      .setLngLat(lngLat)
      .addTo(this.map);
    this.markers.push(marker);
    this.layout.push({ marker, element, lngLat, anchor, offset, priority, hideable, leader });
    return marker;
  }

  /**
   * Greedy screen-space declutter.
   *
   * Cities two hundred km apart are a dozen pixels apart at this zoom, so pins that are
   * tidy around their own city still land on their neighbour's. Rects are computed
   * arithmetically from the projected point rather than read back from the DOM: reading
   * getBoundingClientRect between writes would thrash layout once per marker per frame.
   */
  relayout() {
    const overlaps = (a, b) =>
      !(a.right < b.left || b.right < a.left || a.bottom < b.top || b.bottom < a.top);

    const rectFor = (entry, [bx, by]) => {
      const point = this.map.project(entry.lngLat);
      const [ox, oy] = entry.offset;
      const w = entry.width;
      const h = entry.height;
      const left = point.x + ox + bx - w / 2;
      let top = point.y + oy + by;
      if (entry.anchor === "bottom") top -= h;
      else if (entry.anchor === "center") top -= h / 2;
      return { left, top, right: left + w, bottom: top + h };
    };

    for (const entry of this.layout) {
      entry.width = entry.element.offsetWidth;
      entry.height = entry.element.offsetHeight;
    }

    const order = [...this.layout].sort((a, b) => b.priority - a.priority);
    const placed = [];

    for (const entry of order) {
      const chosen = this.findSlot(entry, placed, rectFor, overlaps);

      if (!chosen && entry.hideable) {
        entry.element.style.visibility = "hidden";
        continue;
      }

      entry.element.style.visibility = "";
      entry.marker.setOffset([
        entry.offset[0] + chosen.bump[0],
        entry.offset[1] + chosen.bump[1],
      ]);
      placed.push(chosen.rect);
      entry.rect = chosen.rect;
    }

    this.drawLeaders();
  }

  /**
   * Search outward from where a marker wants to be, in both axes.
   *
   * A purely vertical search is what turned Hulao, Sishui and Luoyang -- three places
   * within twenty pixels of each other -- into one column of eleven flags climbing off
   * the top of the province. Letting a flag step sideways as well keeps it beside its
   * own city instead. Candidates are ordered by a cost that prefers up-and-slightly-over
   * to far-up, and vertical over horizontal at equal distance, so a genuine crowd still
   * reads as a stack rather than a scatter.
   */
  findSlot(entry, placed, rectFor, overlaps) {
    const stepY = entry.height + 3;
    const stepX = Math.max(28, entry.width * 0.5);

    const candidates = [];
    if (entry.hideable) {
      // Place names only ever get nudged a little; if that fails they are dropped.
      for (const by of [0, 11, 22]) for (const bx of [0, -1, 1]) {
        candidates.push({ bump: [bx * stepX * 0.7, by], cost: by + Math.abs(bx) * 14 });
      }
    } else {
      for (let up = 0; up < 7; up++) {
        for (let across = 0; across <= 3; across++) {
          for (const sign of across === 0 ? [1] : [-1, 1]) {
            candidates.push({
              bump: [sign * across * stepX, -up * stepY],
              cost: up * 10 + across * 13,
            });
          }
        }
      }
    }
    candidates.sort((a, b) => a.cost - b.cost);

    let fallback = null;
    for (const candidate of candidates) {
      const rect = rectFor(entry, candidate.bump);
      const hits = placed.filter((other) => overlaps(rect, other)).length;
      if (hits === 0) return { bump: candidate.bump, rect };
      // Nothing is free: take the least-crowded slot rather than piling onto the last.
      if (!fallback || hits < fallback.hits) fallback = { bump: candidate.bump, rect, hits };
    }
    return entry.hideable ? null : fallback;
  }

  drawLeaders() {
    const lines = [];
    for (const entry of this.layout) {
      if (!entry.leader || !entry.rect) continue;
      const point = this.map.project(entry.lngLat);
      const x = (entry.rect.left + entry.rect.right) / 2;
      const y = entry.rect.bottom;
      // Skip the hairline when the flag is already sitting on its dot.
      if (Math.abs(x - point.x) < 3 && Math.abs(y - point.y) < 14) continue;
      const muted = this.lit && !this.lit.has(entry.element.dataset.character);
      lines.push(
        `<path d="M${point.x.toFixed(1)} ${point.y.toFixed(1)} L${x.toFixed(1)} ${y.toFixed(1)}" ` +
        `stroke="${entry.element.style.color}" opacity="${muted ? 0.1 : 0.45}" />`
      );
    }
    this.leaders.innerHTML = lines.join("");
  }

  flyTo({ lon, lat, zoom }) {
    this.map.easeTo({ center: [lon, lat], zoom, duration: 900 });
  }
}
