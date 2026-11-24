import { readFile, rename, unlink, writeFile } from "node:fs/promises";
import { basename } from "node:path";
import { fileURLToPath } from "node:url";

const API = "https://formulae.brew.sh/api/cask/";
const listPath = process.argv[2] ?? fileURLToPath(new URL("apps.json", import.meta.url));
const outPath = process.argv[3] ?? fileURLToPath(new URL("catalog.json", import.meta.url));
const STORE_HOSTS = ["apps.apple.com", "itunes.apple.com"];
const FETCH_TIMEOUT_MS = 30000;
const USER_FILE_FOLDERS = [
  "~/Desktop",
  "~/Documents",
  "~/Downloads",
  "~/Movies",
  "~/Music",
  "~/Pictures",
  "~/.config",
];
const PROTECTED_ROOTS = new Set([
  "/",
  "~",
  "~/Library",
  "/Library",
  "/Applications",
  "/System",
  "/usr",
  "/etc",
  "/private",
  "/var",
  "/Users",
  "/opt",
  "/bin",
  "/sbin",
  "/tmp",
  "/Volumes",
  "~/Library/Application Support",
  "~/Library/Preferences",
  "~/Library/Caches",
  "~/Library/Containers",
  "~/Library/Group Containers",
  "/Library/Application Support",
  "/Library/Preferences",
  "/Library/Caches",
  "/Library/Containers",
  "/Library/Group Containers",
  "~/Library/Logs",
  "~/Library/Application Scripts",
  "~/Library/Saved Application State",
  "~/Library/HTTPStorages",
  "~/Library/LaunchAgents",
  "~/Library/WebKit",
  "~/Library/Cookies",
  "/Library/LaunchDaemons",
  "/Library/LaunchAgents",
  "/Library/Logs",
  "/Library/PrivilegedHelperTools",
  "/Library/Internet Plug-Ins",
]);

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
    if (app.appBundles !== undefined) {
      const ok =
        Array.isArray(app.appBundles) &&
        app.appBundles.length > 0 &&
        app.appBundles.every((b) => nonEmpty(b) && /^[^*/]+\.app$/.test(b));
      if (!ok) throw new Error(`source list entry ${i}: appBundles must be a list of .app names`);
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

function pathProblem(path) {
  if (typeof path !== "string") return `path is not a string: ${JSON.stringify(path)}`;
  if (!path.startsWith("~/") && !path.startsWith("/")) return `path must start with ~/ or /: ${path}`;
  if (path.includes("#{") || path.includes("${") || path.includes("..")) {
    return `path holds #{, \${ or ..: ${path}`;
  }
  if (path.endsWith("/")) return `path ends with /: ${path}`;
  if (path === "/Users" || path.startsWith("/Users/")) return `path is under /Users: ${path}`;
  if (PROTECTED_ROOTS.has(path)) return `path is a protected root: ${path}`;
  const segments = path.split("/").slice(1);
  if (segments.some((s) => s === "")) return `path has an empty segment: ${path}`;
  if (segments.slice(0, -1).some((s) => s.includes("*"))) {
    return `path has a wildcard before the last segment: ${path}`;
  }
  if (path.startsWith("~/") && segments[0].includes("*")) {
    return `path has a wildcard directly under ~: ${path}`;
  }
  if (path.startsWith("/") && segments.length < 2) return `path is too shallow: ${path}`;
  const parent = path.slice(0, path.lastIndexOf("/"));
  const last = segments[segments.length - 1];
  if (PROTECTED_ROOTS.has(parent) && /^\**$/.test(last)) {
    return `path matches everything under a protected root: ${path}`;
  }
  return null;
}

function inUserFileFolder(path) {
  const lower = path.toLowerCase();
  return USER_FILE_FOLDERS.some((root) => {
    const r = root.toLowerCase();
    return lower === r || lower.startsWith(`${r}/`);
  });
}

function pkgutilEntry(id) {
  if (typeof id !== "string" || !/^[A-Za-z0-9._*-]+$/.test(id)) return null;
  const star = id.indexOf("*");
  if (star !== -1) {
    const literal = id.slice(0, star).split(".").slice(0, -1);
    if (literal.length < 2 || literal.some((seg) => seg === "")) return null;
  }
  return { id, pattern: id.includes("*") };
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
  const skipped = [];
  const fail = (rule) => problems.push(`${app.name} (${app.token}): ${rule}`);

  if (cask.disabled) fail("cask is disabled");
  if (cask.deprecated) fail("cask is deprecated");

  const arm = pickArm64(cask);
  if (!arm) {
    fail("no Apple silicon support");
    return { problems, skipped };
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

  const appBundles = stanza(cask, "app");
  const uninstallDeletes = stanza(cask, "uninstall").flatMap((u) => asList(u.delete));
  const hasApp = appBundles.length > 0;
  const hasPkg = stanza(cask, "pkg").length > 0;
  let installerType = null;
  if (hasApp !== hasPkg) {
    installerType = hasApp ? "app" : "pkg";
  } else if (!hasApp) {
    fail("no app artifact and no pkg artifact");
  } else {
    fail("installer type is not exactly one of copy app and pkg");
  }
  if (!appBundles.every((b) => typeof b === "string" && b.endsWith(".app"))) {
    fail(`app artifact is not a list of .app names: ${JSON.stringify(appBundles)}`);
  }

  if (!nonEmpty(arm.version)) fail("missing version");

  const sha = arm.sha256;
  if (sha !== "no_check" && !/^[0-9a-f]{64}$/.test(sha ?? "")) {
    fail(`checksum is neither a SHA-256 nor no_check: ${sha}`);
  }

  let bundles = appBundles;
  const candidates = stanza(cask, "zap").flatMap((z) =>
    ["trash", "delete", "rmdir"].flatMap((from) => asList(z[from]).map((path) => ({ path, from }))),
  );
  if (candidates.length === 0) fail("missing leftover paths (no zap stanza paths)");
  if (installerType === "pkg") {
    const deleteBundles = [];
    for (const path of uninstallDeletes) {
      if (typeof path === "string" && path.endsWith(".app")) {
        deleteBundles.push(path);
      } else {
        candidates.push({ path, from: "delete" });
      }
    }
    for (const path of deleteBundles) {
      const problem = pathProblem(path);
      if (problem) fail(`uninstall delete ${problem}`);
    }
    bundles = deleteBundles.map((path) => basename(path));
    if (bundles.some((b) => b.includes("*"))) fail(`app bundle name holds a wildcard: ${bundles}`);
    if (bundles.length > 0 && app.appBundles) {
      fail("source list appBundles given, but the cask already names a bundle");
    } else if (bundles.length === 0 && app.appBundles) {
      bundles = app.appBundles;
    }
    if (bundles.length === 0) fail("pkg app has no app bundle in the cask or the source list");
  } else {
    if (app.appBundles) fail("source list appBundles given for an app that is not a pkg app");
    for (const u of stanza(cask, "uninstall")) {
      for (const from of ["delete", "trash"]) {
        for (const path of asList(u[from])) {
          if (typeof path === "string" && path.endsWith(".app")) continue;
          candidates.push({ path, from });
        }
      }
    }
  }
  const leftoverPaths = [];
  for (const candidate of candidates) {
    const problem = pathProblem(candidate.path);
    if (problem) {
      fail(`leftover ${problem}`);
    } else if (inUserFileFolder(candidate.path)) {
      skipped.push(`LEFT OUT ${app.name}: ${candidate.path} (user file folder, ADR-0021)`);
    } else {
      leftoverPaths.push(candidate);
    }
  }

  const rawIds = stanza(cask, "uninstall").flatMap((u) => asList(u.pkgutil));
  const pkgutilIds = [];
  for (const id of rawIds) {
    const entry = pkgutilEntry(id);
    if (entry) {
      pkgutilIds.push(entry);
    } else {
      fail(`pkgutil id is not made of A-Z a-z 0-9 . _ * - or has fewer than two literal segments before *: ${JSON.stringify(id)}`);
    }
  }
  if (installerType === "pkg" && pkgutilIds.length === 0) fail("pkg app has no pkgutil ids");

  if (problems.length > 0) return { problems, skipped };
  return {
    problems,
    skipped,
    entry: {
      name: app.name,
      category: app.category,
      downloadUrl: url,
      version: arm.version,
      installerType,
      appBundles: bundles,
      leftoverPaths,
      pkgutilIds: installerType === "pkg" ? pkgutilIds : [],
      sha256: sha === "no_check" ? null : sha,
    },
  };
}

async function fetchCask(app) {
  const res = await fetch(`${API}${encodeURIComponent(app.token)}.json`, {
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
  });
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
        return cask ? build(app, cask) : { problems, skipped: [] };
      } catch (err) {
        const reason =
          err.name === "TimeoutError" ? `Homebrew API did not answer within ${FETCH_TIMEOUT_MS / 1000}s` : err.message;
        return { problems: [`${app.name} (${app.token}): ${reason}`], skipped: [] };
      }
    }),
  );
  for (const line of results.flatMap((r) => r.skipped)) console.log(line);
  const problems = results.flatMap((r) => r.problems);
  if (problems.length > 0) {
    for (const p of problems) console.error(`REFUSED ${p}`);
    console.error(`No catalog written. ${problems.length} problem(s).`);
    process.exit(1);
  }
  const apps = results.map((r) => r.entry);
  const tempPath = `${outPath}.${process.pid}.tmp`;
  try {
    await writeFile(tempPath, JSON.stringify({ apps }, null, 2) + "\n");
    await rename(tempPath, outPath);
  } catch (err) {
    await unlink(tempPath).catch(() => {});
    throw err;
  }
  console.log(`Wrote ${apps.length} apps to ${outPath}`);
}

main().catch((err) => {
  console.error(`FAILED ${err.message}`);
  process.exit(1);
});
