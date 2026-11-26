import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { closeSync, existsSync, mkdirSync, mkdtempSync, openSync, readFileSync, readSync, readdirSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const catalogPath = resolve(process.argv[2] ?? join(root, "catalog/catalog.json"));
const outDir = resolve(process.argv[3] ?? join(root, "website/public/icons"));
const only = process.argv.slice(4);
const sizes = [128, 256];

function run(cmd, args, options = {}) {
  return execFileSync(cmd, args, { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"], maxBuffer: 64 * 1024 * 1024, ...options });
}

function download(url, file) {
  if (!url.startsWith("https://")) throw new Error(`download URL is not https: ${url}`);
  try {
    run("curl", ["--fail", "--silent", "--show-error", "--location", "--proto", "=https", "--proto-redir", "=https", "--retry", "10", "--retry-all-errors", "--retry-delay", "3", "--output", file, "--", url]);
  } catch (error) {
    throw new Error(`download failed for ${url}: ${String(error.stderr).trim().split("\n").pop()}`);
  }
  return createHash("sha256").update(readFileSync(file)).digest("hex");
}

function walkEntries(base, depth, visit) {
  const walk = (dir, level) => {
    let entries;
    try {
      entries = readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const path = join(dir, entry.name);
      const descend = visit(entry, path);
      if (descend && entry.isDirectory() && level < depth) walk(path, level + 1);
    }
  };
  walk(base, 0);
}

function findDirs(base, name, depth) {
  const found = [];
  walkEntries(base, depth, (entry, path) => {
    if (entry.isDirectory() && entry.name === name) {
      found.push(path);
      return false;
    }
    return true;
  });
  return found;
}

function findFiles(base, suffix, depth) {
  const found = [];
  walkEntries(base, depth, (entry, path) => {
    if (entry.isFile() && entry.name.endsWith(suffix)) found.push(path);
    return true;
  });
  return found;
}

function expandPkg(pkg, dest) {
  run("pkgutil", ["--expand-full", pkg, dest]);
}

function extractTarGz(tarball, dest) {
  const names = run("tar", ["-tzf", tarball]).split("\n").filter(Boolean);
  const kinds = run("tar", ["-tvzf", tarball]).split("\n").filter(Boolean).map((line) => line[0]);
  const wanted = [];
  names.forEach((name, index) => {
    if (name.startsWith("/") || name.split("/").includes("..")) {
      throw new Error(`${tarball} has an unsafe path: ${name}`);
    }
    if (!/^[^/]+\.app\/Contents\/(Info\.plist|Resources\/.+)$/.test(name)) return;
    if (kinds[index] === "l" || kinds[index] === "h") {
      throw new Error(`${tarball} has a link entry among the icon files: ${name}`);
    }
    if (kinds[index] === "-") wanted.push(name);
  });
  mkdirSync(dest);
  if (wanted.length) run("tar", ["-xzf", tarball, "-C", dest, ...wanted]);
}

function zipOffset(file) {
  const fd = openSync(file, "r");
  try {
    const head = Buffer.alloc(64);
    const read = readSync(fd, head, 0, 64, 0);
    return head.subarray(0, read).indexOf(Buffer.from([0x50, 0x4b, 0x03, 0x04]));
  } finally {
    closeSync(fd);
  }
}

function locateBundle(base, bundleName, work) {
  const direct = findDirs(base, bundleName, 3);
  if (direct.length) return direct[0];
  for (const [index, tarball] of findFiles(base, ".tar.gz", 2).entries()) {
    const dest = join(work, `untarred-${index}`);
    extractTarGz(tarball, dest);
    const inside = findDirs(dest, bundleName, 6);
    if (inside.length) return inside[0];
  }
  const pkgs = findFiles(base, ".pkg", 2);
  for (const [index, pkg] of pkgs.entries()) {
    const dest = join(work, `expanded-${index}`);
    expandPkg(pkg, dest);
    const inside = findDirs(dest, bundleName, 14);
    if (inside.length) return inside[0];
  }
  return null;
}

function plistValue(plist, key) {
  try {
    return run("plutil", ["-extract", key, "raw", "-o", "-", plist]).trim();
  } catch {
    return null;
  }
}

function render(bundle, work, token) {
  const iconFile = plistValue(join(bundle, "Contents/Info.plist"), "CFBundleIconFile");
  const resources = join(bundle, "Contents/Resources");
  let source = null;
  if (iconFile) {
    const name = iconFile.endsWith(".icns") ? iconFile : `${iconFile}.icns`;
    if (existsSync(join(resources, name))) source = join(resources, name);
  }
  if (!source) {
    const thumbDir = join(work, "thumb");
    mkdirSync(thumbDir);
    run("qlmanage", ["-t", "-s", "512", "-o", thumbDir, bundle]);
    const thumbs = readdirSync(thumbDir).filter((file) => file.endsWith(".png"));
    if (!thumbs.length) throw new Error("no CFBundleIconFile and no asset catalog icon could be rendered");
    source = join(thumbDir, thumbs[0]);
  }
  return sizes.map((size) => {
    const file = join(work, `${token}-${size}.png`);
    run("sips", ["-s", "format", "png", "-z", String(size), String(size), source, "--out", file]);
    return [size, file];
  });
}

async function processApp(app, scratch) {
  const work = mkdtempSync(join(scratch, `${app.token}-`));
  const archive = join(work, "download");
  const content = join(work, "content");
  mkdirSync(content);
  let mountPoint = null;
  try {
    const sha256 = download(app.downloadUrl, archive);
    if (app.sha256 && app.sha256.toLowerCase() !== sha256) {
      throw new Error(`SHA-256 mismatch: catalog ${app.sha256}, download ${sha256}`);
    }
    const bundleName = app.appBundles[0];
    const type = run("file", ["-b", archive]);
    let base = content;
    const offset = zipOffset(archive);
    if (offset > 0) {
      const unwrapped = join(work, "unwrapped.zip");
      writeFileSync(unwrapped, readFileSync(archive).subarray(offset));
      run("ditto", ["-x", "-k", unwrapped, content]);
    } else if (/Zip archive/i.test(type)) {
      run("ditto", ["-x", "-k", archive, content]);
    } else if (/xar archive/i.test(type)) {
      expandPkg(archive, join(content, "pkg"));
    } else {
      const target = join(work, "mount");
      mkdirSync(target);
      mountPoint = target;
      run("hdiutil", ["attach", "-nobrowse", "-readonly", "-noautoopen", "-mountpoint", target, archive], { input: "Y\n" });
      base = target;
    }
    const bundle = locateBundle(base, bundleName, work);
    if (!bundle) throw new Error(`${bundleName} not found in the download`);
    const rendered = render(bundle, work, app.token);
    const staged = rendered.map(([size, file]) => {
      const target = join(outDir, `${app.token}-${size}.png`);
      const temp = `${target}.tmp`;
      run("cp", [file, temp]);
      return [temp, target];
    });
    for (const [temp, target] of staged) renameSync(temp, target);
    return { name: app.name, sourceUrl: app.downloadUrl, version: app.version, sha256, bundle: bundleName };
  } finally {
    if (mountPoint) {
      try {
        run("hdiutil", ["detach", mountPoint]);
      } catch {
        try {
          run("hdiutil", ["detach", "-force", mountPoint]);
        } catch {}
      }
    }
    rmSync(work, { recursive: true, force: true });
  }
}

const catalog = JSON.parse(readFileSync(catalogPath, "utf8"));
mkdirSync(outDir, { recursive: true });
const manifestPath = join(outDir, "manifest.json");
const manifest = existsSync(manifestPath) ? JSON.parse(readFileSync(manifestPath, "utf8")) : { icons: {} };
const scratch = mkdtempSync("/private/tmp/settlein-icons-");
const failures = [];

try {
  for (const app of catalog.apps) {
    if (only.length && !only.includes(app.token)) continue;
    try {
      manifest.icons[app.token] = await processApp(app, scratch);
      console.log(`ok    ${app.token}`);
    } catch (error) {
      failures.push(app.name);
      console.error(`FAIL  ${app.name} (${app.token}): ${String(error.message).split("\n")[0]}`);
    }
  }
} finally {
  rmSync(scratch, { recursive: true, force: true });
}

const sorted = Object.fromEntries(Object.entries(manifest.icons).sort(([a], [b]) => a.localeCompare(b)));
const temp = `${manifestPath}.tmp`;
writeFileSync(temp, `${JSON.stringify({ icons: sorted }, null, 2)}\n`);
renameSync(temp, manifestPath);

if (failures.length) {
  console.error(`No icon for: ${failures.join(", ")}`);
  process.exit(1);
}
