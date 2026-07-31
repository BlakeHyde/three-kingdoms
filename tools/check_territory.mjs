/*
 * Geometry regression check for the territory builder.
 *
 *     node tools/check_territory.mjs
 *
 * Exists because of a bug that no data validation could have caught: where two cells
 * of one faction met only at a corner, the ring tracer lost an edge, the walk dead-
 * ended, and the ring was closed straight across the map -- drawing a long thin wedge
 * over ten chapters. The data was fine; the geometry was not.
 *
 * Two invariants, both cheap:
 *   - every ring is closed (first point === last point)
 *   - no step between consecutive points exceeds the sampling grid, since a boundary
 *     is traced cell by cell and physically cannot jump further than one cell
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const DATA = path.join(ROOT, "web", "data");
const read = (p) => JSON.parse(fs.readFileSync(path.join(DATA, p), "utf8"));

const { buildLandMask, buildTerritories } = await import(
  path.join(ROOT, "web", "js", "territory.js")
);

const GRID_STEP = 0.2;      // must match territory.js
const MAX_STEP = GRID_STEP * 1.5;

buildLandMask(read("basemap/landmask.geojson"));
const corpus = read("corpus.json");

const problems = [];

for (const chapter of corpus.chapters) {
  const collection = buildTerritories(chapter.control, corpus.places, corpus.factions);

  for (const feature of collection.features) {
    const faction = feature.properties.faction;
    for (const polygon of feature.geometry.coordinates) {
      for (const ring of polygon) {
        const [first, last] = [ring[0], ring[ring.length - 1]];
        if (first[0] !== last[0] || first[1] !== last[1]) {
          problems.push(`ch${chapter.n} ${faction}: unclosed ring`);
        }
        for (let k = 1; k < ring.length; k++) {
          const dx = ring[k][0] - ring[k - 1][0];
          const dy = ring[k][1] - ring[k - 1][1];
          const step = Math.hypot(dx, dy);
          if (step > MAX_STEP) {
            problems.push(
              `ch${chapter.n} ${faction}: ${step.toFixed(2)}deg jump between ` +
              `[${ring[k - 1]}] and [${ring[k]}] (grid is ${GRID_STEP})`
            );
          }
        }
      }
    }
  }
}

if (problems.length) {
  console.error(`${problems.length} geometry problem(s):\n`);
  for (const p of problems.slice(0, 25)) console.error(`  - ${p}`);
  if (problems.length > 25) console.error(`  ... and ${problems.length - 25} more`);
  process.exit(1);
}

console.log(`  ${corpus.chapters.length} chapters: all rings closed, no impossible jumps`);
