import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const catalogPath = resolve(process.cwd(), "../catalog/catalog.json");
const sourcePath = resolve(process.cwd(), "../catalog/apps.json");

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
  const source = readJson(sourcePath);

  if (!catalog || !Array.isArray(catalog.apps) || catalog.apps.length === 0) {
    fail(`${catalogPath} has no "apps" array with entries`);
  }
  if (!Array.isArray(source) || source.length === 0) {
    fail(`${sourcePath} is not a non-empty array`);
  }

  const tokenByName = new Map();
  for (const entry of source) {
    if (typeof entry.name !== "string" || typeof entry.token !== "string" || !entry.name || !entry.token) {
      fail(`${sourcePath} has an entry without a name or token`);
    }
    if (tokenByName.has(entry.name)) fail(`${sourcePath} lists "${entry.name}" twice`);
    tokenByName.set(entry.name, { token: entry.token, category: entry.category });
  }

  const seen = new Set();
  const groups = new Map();
  for (const app of catalog.apps) {
    if (typeof app.name !== "string" || !app.name.trim()) fail("a catalog app has no name");
    if (typeof app.category !== "string" || !app.category.trim()) {
      fail(`catalog app "${app.name}" has no category`);
    }
    const sourceEntry = tokenByName.get(app.name);
    if (!sourceEntry) fail(`catalog app "${app.name}" has no matching entry in ${sourcePath}`);
    if (sourceEntry.category !== app.category) {
      fail(`"${app.name}" is in category "${sourceEntry.category}" in ${sourcePath} but "${app.category}" in ${catalogPath}`);
    }
    const token = sourceEntry.token;
    if (seen.has(app.name)) fail(`catalog app "${app.name}" appears twice`);
    seen.add(app.name);
    if (!groups.has(app.category)) groups.set(app.category, []);
    groups.get(app.category).push({ name: app.name, token });
  }

  for (const name of tokenByName.keys()) {
    if (!seen.has(name)) fail(`"${name}" is in ${sourcePath} but missing from the catalog file`);
  }

  return [...groups].map(([category, apps]) => ({
    category,
    id: category.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""),
    apps,
  }));
}
