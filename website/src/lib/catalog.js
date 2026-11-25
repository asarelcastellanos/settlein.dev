import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

const catalogPath = resolve(process.cwd(), "../catalog/catalog.json");
const iconDir = resolve(process.cwd(), "public/icons");
const iconSizes = [128, 256];

function readJson(path) {
  let text;
  try {
    text = readFileSync(path, "utf8");
  } catch (error) {
    throw new Error(`Catalog page: cannot read ${path} (${error.code}). Build stopped.`);
  }
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new Error(`Catalog page: ${path} is not valid JSON (${error.message}). Build stopped.`);
  }
}

function fail(message) {
  throw new Error(`Catalog page: ${message}. Build stopped.`);
}

export function loadCatalog() {
  const catalog = readJson(catalogPath);

  if (!catalog || !Array.isArray(catalog.apps) || catalog.apps.length === 0) {
    fail(`${catalogPath} has no "apps" array with entries`);
  }
  const seen = new Set();
  const tokens = new Set();
  const groups = new Map();
  for (const app of catalog.apps) {
    if (typeof app.name !== "string" || !app.name.trim()) fail("a catalog app has no name");
    if (typeof app.category !== "string" || !app.category.trim()) {
      fail(`catalog app "${app.name}" has no category`);
    }
    if (typeof app.token !== "string" || !/^[a-z0-9-]+$/.test(app.token)) {
      fail(`catalog app "${app.name}" has a missing or invalid token`);
    }
    if (tokens.has(app.token)) fail(`catalog token "${app.token}" appears twice`);
    tokens.add(app.token);
    for (const size of iconSizes) {
      if (!existsSync(resolve(iconDir, `${app.token}-${size}.png`))) {
        fail(`catalog app "${app.name}" has no icon file public/icons/${app.token}-${size}.png`);
      }
    }
    if (seen.has(app.name)) fail(`catalog app "${app.name}" appears twice`);
    seen.add(app.name);
    if (!groups.has(app.category)) groups.set(app.category, []);
    groups.get(app.category).push({ name: app.name, token: app.token });
  }

  return [...groups].map(([category, apps], position) => ({
    first: position === 0,
    category,
    id: category.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""),
    apps,
  }));
}
