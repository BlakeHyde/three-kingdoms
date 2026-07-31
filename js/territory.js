/*
 * Turns "who holds which cities" into filled territory.
 *
 * Hand-drawing 120 chapters x a dozen factions of boundary polygons is not a thing
 * anyone would finish, and it would be false precision anyway: nobody knows where Yuan
 * Shu's writ stopped in 193. So a chapter states only its control points, and this
 * builds the regions:
 *
 *   1. sample a grid over the map, keeping cells that are on land
 *   2. assign each cell to whichever faction's nearest holding is closest, scaled by
 *      that holding's political weight -- a provincial capital reaches much further
 *      than a mountain pass -- and leave it unclaimed if nothing is near enough
 *   3. trace the boundary of each faction's cells and round the corners off
 *
 * The result is a weighted Voronoi with an empty frontier, which is about as honest as
 * a filled map of this period can be.
 */

const GRID_STEP = 0.2;          // degrees; ~22 km, fine enough that smoothing hides it
const KM_PER_WEIGHT = 78;       // how far one unit of `weight` projects control
const SMOOTH_PASSES = 3;        // Chaikin rounds

const WINDOW = { west: 92, east: 132, south: 15, north: 50 };

const cols = Math.round((WINDOW.east - WINDOW.west) / GRID_STEP);
const rows = Math.round((WINDOW.north - WINDOW.south) / GRID_STEP);

const cellLon = (i) => WINDOW.west + (i + 0.5) * GRID_STEP;
const cellLat = (j) => WINDOW.south + (j + 0.5) * GRID_STEP;

/* ------------------------------------------------------------------ land mask */

let landMask = null; // Uint8Array, one byte per cell

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
  const owner = new Int16Array(cols * rows).fill(-1);
  const factionIds = Object.keys(control);

  const sites = [];
  factionIds.forEach((fid, index) => {
    for (const placeId of control[fid]) {
      const place = places[placeId];
      if (!place) continue;
      sites.push({
        faction: index,
        lon: place.lon,
        lat: place.lat,
        reach: KM_PER_WEIGHT * ((place.weight ?? 1) + 1),
      });
    }
  });

  for (let j = 0; j < rows; j++) {
    const lat = cellLat(j);
    const lonScale = Math.cos((lat * Math.PI) / 180) * KM_PER_DEG;
    for (let i = 0; i < cols; i++) {
      const index = j * cols + i;
      if (!landMask[index]) continue;
      const lon = cellLon(i);

      let best = Infinity;
      let bestFaction = -1;
      for (const site of sites) {
        const dx = (lon - site.lon) * lonScale;
        const dy = (lat - site.lat) * KM_PER_DEG;
        // Normalising by reach is what makes this a *weighted* Voronoi: a capital
        // out-competes a nearer village.
        const score = Math.sqrt(dx * dx + dy * dy) / site.reach;
        if (score < best) { best = score; bestFaction = site.faction; }
      }
      if (best <= 1) owner[index] = bestFaction;
    }
  }
  return { owner, factionIds };
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
  const edges = new Map(); // "x,y" of start -> end point

  const key = (x, y) => `${x},${y}`;

  for (let j = 0; j < rows; j++) {
    for (let i = 0; i < cols; i++) {
      if (!has(i, j)) continue;
      if (!has(i, j - 1)) edges.set(key(i, j), [i + 1, j]);
      if (!has(i + 1, j)) edges.set(key(i + 1, j), [i + 1, j + 1]);
      if (!has(i, j + 1)) edges.set(key(i + 1, j + 1), [i, j + 1]);
      if (!has(i - 1, j)) edges.set(key(i, j + 1), [i, j]);
    }
  }

  const rings = [];
  while (edges.size) {
    const startKey = edges.keys().next().value;
    const [sx, sy] = startKey.split(",").map(Number);
    const ring = [[sx, sy]];
    let cursor = startKey;

    while (edges.has(cursor)) {
      const next = edges.get(cursor);
      edges.delete(cursor);
      ring.push(next);
      cursor = key(next[0], next[1]);
      if (cursor === startKey) break;
    }
    if (ring.length > 4) rings.push(ring);
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
