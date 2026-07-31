/*
 * Turns "who holds which cities" into filled territory.
 *
 * Hand-drawing 120 chapters x a dozen factions of boundary polygons is not a thing
 * anyone would finish, and it would be false precision anyway: nobody knows where Yuan
 * Shu's writ stopped in 193. So a chapter states only its control points, and this
 * builds the regions:
 *
 *   1. sample a grid over the map, keeping cells that are on land
 *   2. spread control outward from each holding over that grid, spending a budget set
 *      by the holding's political weight, and charging more to cross high or steep
 *      ground; a cell goes to whichever faction reaches it most cheaply, and stays
 *      unclaimed if nobody can afford it
 *   3. trace the boundary of each faction's cells and round the corners off
 *
 * Step 2 is a least-cost spread rather than straight-line distance, because straight
 * lines get this period badly wrong: they run Liu Zhang's authority from Chengdu over
 * the Daliang Shan and deep into Yunnan, when that country was Meng Huo's precisely
 * because Chengdu could not hold it. Control here followed valleys and stopped at
 * ranges. It also means control cannot cross open sea, which is correct: Liaodong is
 * reachable by the coast road and not otherwise.
 *
 * The result is a terrain-weighted Voronoi with an empty frontier, which is about as
 * honest as a filled map of this period can be.
 */

const GRID_STEP = 0.2;          // degrees; ~22 km, fine enough that smoothing hides it
const KM_PER_WEIGHT = 78;       // how far one unit of `weight` projects control
const SMOOTH_PASSES = 3;        // Chaikin rounds

// Terrain friction. A step costs its horizontal distance multiplied by
//   1 + ELEVATION_TAX * (mean elevation in km) + SLOPE_TAX * (gradient)
// so the Sichuan basin is nearly free, the Yunnan plateau is expensive to hold from
// anywhere, and a range crossing costs several times its map distance. Both are tuning
// knobs, not measurements -- they are set so the resulting frontiers match where the
// novel actually places the boundaries.
const ELEVATION_TAX = 0.55;
const SLOPE_TAX = 9.0;
const MAX_FRICTION = 12;        // a cliff is not infinitely expensive, just prohibitive

const WINDOW = { west: 92, east: 132, south: 15, north: 50 };

const cols = Math.round((WINDOW.east - WINDOW.west) / GRID_STEP);
const rows = Math.round((WINDOW.north - WINDOW.south) / GRID_STEP);

const cellLon = (i) => WINDOW.west + (i + 0.5) * GRID_STEP;
const cellLat = (j) => WINDOW.south + (j + 0.5) * GRID_STEP;

/* ------------------------------------------------------------------ land mask */

let landMask = null;  // Uint8Array, one byte per cell
let elevation = null; // Uint16Array of decimetres, same indexing as landMask

/** Elevation grid from tools/build_elevation.py: uint16 decimetres, row 0 = south. */
export function setElevation(grid) {
  if (grid.length !== cols * rows) {
    throw new Error(`elevation grid is ${grid.length}, expected ${cols * rows}`);
  }
  elevation = grid;
}

function ringsOf(geometry) {
  if (geometry.type === "Polygon") return [geometry.coordinates];
  if (geometry.type === "MultiPolygon") return geometry.coordinates;
  return [];
}

function pointInRing(lon, lat, ring) {
  let inside = false;
  for (let k = 0, m = ring.length - 1; k < ring.length; m = k++) {
    const [xi, yi] = ring[k];
    const [xj, yj] = ring[m];
    if ((yi > lat) !== (yj > lat) && lon < ((xj - xi) * (lat - yi)) / (yj - yi) + xi) {
      inside = !inside;
    }
  }
  return inside;
}

/**
 * Precompute which grid cells are on land. Runs once; every chapter reuses it.
 * Polygons are bounding-boxed first because the great majority of cells are sea and
 * can be rejected without walking a single ring.
 */
export function buildLandMask(landGeoJSON) {
  landMask = new Uint8Array(cols * rows);

  const polys = [];
  for (const feature of landGeoJSON.features) {
    for (const rings of ringsOf(feature.geometry)) {
      const outer = rings[0];
      let west = Infinity, east = -Infinity, south = Infinity, north = -Infinity;
      for (const [x, y] of outer) {
        if (x < west) west = x;
        if (x > east) east = x;
        if (y < south) south = y;
        if (y > north) north = y;
      }
      polys.push({ rings, west, east, south, north });
    }
  }

  for (let j = 0; j < rows; j++) {
    const lat = cellLat(j);
    for (let i = 0; i < cols; i++) {
      const lon = cellLon(i);
      for (const p of polys) {
        if (lon < p.west || lon > p.east || lat < p.south || lat > p.north) continue;
        if (!pointInRing(lon, lat, p.rings[0])) continue;
        // Rings after the first are holes (inland seas), which are not land.
        let inHole = false;
        for (let h = 1; h < p.rings.length; h++) {
          if (pointInRing(lon, lat, p.rings[h])) { inHole = true; break; }
        }
        if (!inHole) { landMask[j * cols + i] = 1; break; }
      }
    }
  }
  return landMask;
}

/* ------------------------------------------------------------- influence field */

// Equirectangular is plenty at this scale and avoids a trig call per cell per site.
const KM_PER_DEG = 111.32;

function assignCells(control, places) {
  if (!elevation) throw new Error("setElevation() must run before buildTerritories()");

  const total = cols * rows;
  const cost = new Float32Array(total).fill(Infinity);
  const owner = new Int16Array(total).fill(-1);
  const budget = new Float32Array(total);      // reach of whichever site got here
  const factionIds = Object.keys(control);

  // -- seed every holding
  const heap = new MinHeap(total);
  factionIds.forEach((fid, index) => {
    for (const placeId of control[fid]) {
      const place = places[placeId];
      if (!place) continue;
      const seed = nearestLandCell(place.lon, place.lat);
      if (seed < 0) continue;                  // holding is nowhere near land
      const reach = KM_PER_WEIGHT * ((place.weight ?? 1) + 1);
      // A cell seeded twice keeps the stronger claim, so a capital is not demoted by a
      // village sharing its grid square.
      if (cost[seed] === 0 && budget[seed] >= reach) continue;
      cost[seed] = 0;
      owner[seed] = index;
      budget[seed] = reach;
      heap.push(0, seed);
    }
  });

  // -- spread outward, cheapest first
  // Dijkstra over the grid. Each cell's score is the fraction of its origin's budget
  // spent getting there, so a cell is claimed while that stays under 1. Edge weights
  // depend on which site the path came from, which is fine: this is just every site's
  // search running at once, with the origin carried along.
  while (heap.size) {
    const node = heap.pop();
    // Lazy deletion: a cell can be queued several times as cheaper routes are found,
    // so drop any copy whose key is worse than the best cost recorded for that cell.
    if (heap.lastKey > cost[node]) continue;
    const here = cost[node];

    const i = node % cols;
    const j = (node - i) / cols;
    const lat = cellLat(j);
    const lonScale = Math.cos((lat * Math.PI) / 180) * KM_PER_DEG;
    const elevHere = elevation[node] / 10000;                            // decimetres -> km
    const reach = budget[node];

    for (let dj = -1; dj <= 1; dj++) {
      const nj = j + dj;
      if (nj < 0 || nj >= rows) continue;
      for (let di = -1; di <= 1; di++) {
        if (di === 0 && dj === 0) continue;
        const ni = i + di;
        if (ni < 0 || ni >= cols) continue;

        const next = nj * cols + ni;
        if (!landMask[next]) continue;

        const dx = di * GRID_STEP * lonScale;
        const dy = dj * GRID_STEP * KM_PER_DEG;
        const stepKm = Math.sqrt(dx * dx + dy * dy);

        const elevNext = elevation[next] / 10000;
        const meanKm = (elevHere + elevNext) / 2;
        const gradient = Math.abs(elevNext - elevHere) / stepKm;
        const friction = Math.min(
          MAX_FRICTION,
          1 + ELEVATION_TAX * meanKm + SLOPE_TAX * gradient
        );

        const candidate = here + (stepKm * friction) / reach;
        if (candidate >= 1 || candidate >= cost[next]) continue;

        cost[next] = candidate;
        owner[next] = owner[node];
        budget[next] = reach;
        heap.push(candidate, next);
      }
    }
  }
  return { owner, factionIds };
}

/** Snap a holding to a land cell, searching outward a little for coastal sites whose
 *  centre lands in the sea at this resolution. */
function nearestLandCell(lon, lat) {
  const i0 = Math.floor((lon - WINDOW.west) / GRID_STEP);
  const j0 = Math.floor((lat - WINDOW.south) / GRID_STEP);
  for (let radius = 0; radius <= 3; radius++) {
    for (let dj = -radius; dj <= radius; dj++) {
      for (let di = -radius; di <= radius; di++) {
        if (radius > 0 && Math.abs(di) !== radius && Math.abs(dj) !== radius) continue;
        const i = i0 + di;
        const j = j0 + dj;
        if (i < 0 || j < 0 || i >= cols || j >= rows) continue;
        const index = j * cols + i;
        if (landMask[index]) return index;
      }
    }
  }
  return -1;
}

/** Binary min-heap over (key, value) pairs, sized once. Lazy deletion: a node can be
 *  pushed more than once and stale copies are skipped when popped. */
class MinHeap {
  constructor(capacity) {
    this.keys = new Float32Array(capacity * 4);
    this.values = new Int32Array(capacity * 4);
    this.size = 0;
    this.lastKey = 0;
  }

  push(key, value) {
    if (this.size === this.keys.length) this.grow();
    let n = this.size++;
    this.keys[n] = key;
    this.values[n] = value;
    while (n > 0) {
      const parent = (n - 1) >> 1;
      if (this.keys[parent] <= this.keys[n]) break;
      this.swap(parent, n);
      n = parent;
    }
  }

  pop() {
    const top = this.values[0];
    this.lastKey = this.keys[0];
    this.size--;
    if (this.size > 0) {
      this.keys[0] = this.keys[this.size];
      this.values[0] = this.values[this.size];
      let n = 0;
      for (;;) {
        const left = 2 * n + 1;
        const right = left + 1;
        let smallest = n;
        if (left < this.size && this.keys[left] < this.keys[smallest]) smallest = left;
        if (right < this.size && this.keys[right] < this.keys[smallest]) smallest = right;
        if (smallest === n) break;
        this.swap(smallest, n);
        n = smallest;
      }
    }
    return top;
  }

  swap(a, b) {
    const k = this.keys[a]; this.keys[a] = this.keys[b]; this.keys[b] = k;
    const v = this.values[a]; this.values[a] = this.values[b]; this.values[b] = v;
  }

  grow() {
    const keys = new Float32Array(this.keys.length * 2);
    const values = new Int32Array(this.values.length * 2);
    keys.set(this.keys); values.set(this.values);
    this.keys = keys; this.values = values;
  }
}

/* ------------------------------------------------------------ boundary tracing */

/**
 * Walk the border between claimed and unclaimed cells.
 *
 * Emitting each boundary edge counter-clockwise around its own cell means the edges of
 * a region chain head-to-tail into closed rings with no special cases -- exteriors come
 * out counter-clockwise, holes clockwise, which is exactly the GeoJSON convention.
 */
function traceRings(owner, faction) {
  const has = (i, j) => i >= 0 && j >= 0 && i < cols && j < rows && owner[j * cols + i] === faction;

  // One vertex can start TWO boundary edges, where two cells of this faction meet only
  // at a corner. Storing a single edge per vertex silently dropped one of them, the
  // walk then ran out of edges mid-ring, and the ring got closed across the map --
  // which is where the long thin wedges came from. So: a list per vertex.
  const edges = new Map();
  const key = (x, y) => `${x},${y}`;
  const addEdge = (x, y, end) => {
    const k = key(x, y);
    const existing = edges.get(k);
    if (existing) existing.push(end);
    else edges.set(k, [end]);
  };

  for (let j = 0; j < rows; j++) {
    for (let i = 0; i < cols; i++) {
      if (!has(i, j)) continue;
      if (!has(i, j - 1)) addEdge(i, j, [i + 1, j]);
      if (!has(i + 1, j)) addEdge(i + 1, j, [i + 1, j + 1]);
      if (!has(i, j + 1)) addEdge(i + 1, j + 1, [i, j + 1]);
      if (!has(i - 1, j)) addEdge(i, j + 1, [i, j]);
    }
  }

  const rings = [];
  while (edges.size) {
    const startKey = edges.keys().next().value;
    const [sx, sy] = startKey.split(",").map(Number);
    const ring = [[sx, sy]];
    let cursor = startKey;

    for (;;) {
      const outgoing = edges.get(cursor);
      if (!outgoing || !outgoing.length) break;
      const next = outgoing.pop();
      if (!outgoing.length) edges.delete(cursor);
      ring.push(next);
      cursor = key(next[0], next[1]);
      if (cursor === startKey) break;
    }

    // Only keep rings that actually returned to their start. A walk that dead-ends is
    // a bug, not a shape, and closing it anyway is what drew the artefact.
    if (cursor === startKey && ring.length > 4) rings.push(ring);
  }
  return rings;
}

function signedArea(ring) {
  let sum = 0;
  for (let k = 0, m = ring.length - 1; k < ring.length; m = k++) {
    sum += (ring[m][0] - ring[k][0]) * (ring[m][1] + ring[k][1]);
  }
  return sum / 2;
}

/** Chaikin corner-cutting: replaces the staircase with something map-shaped. */
function smooth(ring, passes) {
  let points = ring;
  for (let pass = 0; pass < passes; pass++) {
    const out = [];
    for (let k = 0; k < points.length - 1; k++) {
      const [x0, y0] = points[k];
      const [x1, y1] = points[k + 1];
      out.push([x0 * 0.75 + x1 * 0.25, y0 * 0.75 + y1 * 0.25]);
      out.push([x0 * 0.25 + x1 * 0.75, y0 * 0.25 + y1 * 0.75]);
    }
    out.push(out[0]);
    points = out;
  }
  return points;
}

const toLngLat = ([i, j]) => [
  +(WINDOW.west + i * GRID_STEP).toFixed(4),
  +(WINDOW.south + j * GRID_STEP).toFixed(4),
];

function ringContains(outer, point) {
  return pointInRing(point[0], point[1], outer);
}

/* -------------------------------------------------------------------- public API */

/**
 * @returns {GeoJSON.FeatureCollection} one MultiPolygon per faction, painted in the
 *   order given by each faction's `rank`.
 */
export function buildTerritories(control, places, factions) {
  if (!landMask) throw new Error("buildLandMask() must run before buildTerritories()");

  const { owner, factionIds } = assignCells(control, places);
  const features = [];

  factionIds.forEach((fid, index) => {
    const rings = traceRings(owner, index).map((r) => smooth(r, SMOOTH_PASSES).map(toLngLat));
    if (!rings.length) return;

    const exteriors = [];
    const holes = [];
    for (const ring of rings) (signedArea(ring) > 0 ? exteriors : holes).push(ring);

    const polygons = exteriors.map((ext) => [ext]);
    for (const hole of holes) {
      const target = polygons.find((poly) => ringContains(poly[0], hole[0]));
      if (target) target.push(hole);
    }
    if (!polygons.length) return;

    features.push({
      type: "Feature",
      properties: { faction: fid, rank: factions[fid]?.rank ?? 50 },
      geometry: { type: "MultiPolygon", coordinates: polygons },
    });
  });

  features.sort((a, b) => b.properties.rank - a.properties.rank);
  return { type: "FeatureCollection", features };
}
