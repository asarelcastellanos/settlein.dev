import { readFile, writeFile } from "node:fs/promises";

const API = "https://formulae.brew.sh/api/cask/";
const listPath = process.argv[2] ?? new URL("apps.json", import.meta.url).pathname;
const outPath = process.argv[3] ?? new URL("catalog.json", import.meta.url).pathname;
const STORE_HOSTS = ["apps.apple.com", "itunes.apple.com"];

const nonEmpty = (v) => typeof v === "string" && v.trim() !== "";

function readList(text) {
  const list = JSON.parse(text);
  if (!Array.isArray(list) || list.length === 0) {
    throw new Error("source list: must be a non-empty array");
  }
  const seen = new Set();
  for (const [i, app] of list.entries()) {
    for (const key of ["name", "category", "token"]) {
      if (!nonEmpty(app?.[key])) {
        throw new Error(`source list entry ${i}: missing ${key}`);
      }
    }
    if (seen.has(app.token)) {
      throw new Error(`source list: duplicate token ${app.token}`);
    }
    seen.add(app.token);
  }
  return list;
}

function asList(value) {
  if (value === undefined || value === null) return [];
  return Array.isArray(value) ? value : [value];
}

function pickArm64(cask) {
  const platform = (cask.supported_platforms ?? []).find((p) => p.startsWith("arm64_"));
  const arch = cask.depends_on?.arch;
  const intelOnly = arch !== undefined && !JSON.stringify(arch).includes("arm64");
  if (!platform || intelOnly) return null;
  return { ...cask, ...(cask.variations?.[platform] ?? {}) };
}

function stanza(cask, key) {
  return cask.artifacts.filter((a) => key in a).flatMap((a) => asList(a[key]));
}

function build(app, cask) {
  const problems = [];
  const fail = (rule) => problems.push(`${app.name} (${app.token}): ${rule}`);

  if (cask.disabled) fail("cask is disabled");
  if (cask.deprecated) fail("cask is deprecated");

  const arm = pickArm64(cask);
  if (!arm) {
    fail("no Apple silicon support");
    return { problems };
  }

  const url = arm.url;
  if (!nonEmpty(url)) {
    fail("missing download link");
  } else {
    let host = "";
    try {
      host = new URL(url).hostname;
    } catch {
      fail(`download link is not a valid URL: ${url}`);
    }
    if (STORE_HOSTS.includes(host)) fail(`download link is on the Mac App Store: ${url}`);
  }

  const hasApp = stanza(cask, "app").length > 0;
  const hasPkg = stanza(cask, "pkg").length > 0;
  let installerType = null;
  if (hasApp !== hasPkg) {
    installerType = hasApp ? "app" : "pkg";
  } else {
    fail("installer type is not exactly one of copy app and pkg");
  }

  if (!nonEmpty(arm.version)) fail("missing version");

  const sha = arm.sha256;
  if (sha !== "no_check" && !/^[0-9a-f]{64}$/.test(sha ?? "")) {
    fail(`checksum is neither a SHA-256 nor no_check: ${sha}`);
  }

  const leftoverPaths = stanza(cask, "zap").flatMap((z) =>
    ["trash", "delete", "rmdir"].flatMap((k) => asList(z[k])),
  );
  if (leftoverPaths.length === 0) fail("missing leftover paths (no zap stanza paths)");

  const pkgutilIds = stanza(cask, "uninstall").flatMap((u) => asList(u.pkgutil));
  if (installerType === "pkg" && pkgutilIds.length === 0) fail("pkg app has no pkgutil ids");

  if (problems.length > 0) return { problems };
  return {
    problems,
    entry: {
      name: app.name,
      category: app.category,
      downloadUrl: url,
      version: arm.version,
      installerType,
      leftoverPaths,
      pkgutilIds: installerType === "pkg" ? pkgutilIds : [],
      sha256: sha === "no_check" ? null : sha,
    },
  };
}

async function fetchCask(app) {
  const res = await fetch(`${API}${encodeURIComponent(app.token)}.json`);
  if (res.status === 404) return { problems: [`${app.name} (${app.token}): cask not found in Homebrew`] };
  if (!res.ok) return { problems: [`${app.name} (${app.token}): Homebrew API answered HTTP ${res.status}`] };
  return { cask: await res.json() };
}

async function main() {
  const list = readList(await readFile(listPath, "utf8"));
  const results = await Promise.all(
    list.map(async (app) => {
      try {
        const { cask, problems } = await fetchCask(app);
        return cask ? build(app, cask) : { problems };
      } catch (err) {
        return { problems: [`${app.name} (${app.token}): ${err.message}`] };
      }
    }),
  );
  const problems = results.flatMap((r) => r.problems);
  if (problems.length > 0) {
    for (const p of problems) console.error(`REFUSED ${p}`);
    console.error(`No catalog written. ${problems.length} problem(s).`);
    process.exit(1);
  }
  const apps = results.map((r) => r.entry);
  await writeFile(outPath, JSON.stringify({ apps }, null, 2) + "\n");
  console.log(`Wrote ${apps.length} apps to ${outPath}`);
}

main().catch((err) => {
  console.error(`FAILED ${err.message}`);
  process.exit(1);
});
