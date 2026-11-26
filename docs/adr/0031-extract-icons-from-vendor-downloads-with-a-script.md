---
status: accepted
date: 2026-11-25
---
# 0031. Extract icons from vendor downloads with a script

Accepted by default, not reviewed by the owner.

## Context and problem statement

ADR-0026 bundles one icon file per catalog app. The catalog holds no icon field, so each icon must come from the app itself. Doing this by hand for 44 apps does not repeat when the catalog changes.

## Considered options

* A Node script that downloads each vendor file, checks its SHA-256, and renders the icon from the app bundle
* Copy icons from Homebrew or a third-party icon set
* Export each icon by hand from an installed app

## Decision outcome

Chosen option: "A Node script", because the icon then comes from the same file the user installs, and the script records where each icon came from.

`scripts/extract-icons.mjs` takes the catalog file, an output folder and optional tokens. For each app it downloads the vendor URL over https and compares the SHA-256 with the catalog when the catalog has one. It finds the app bundle in the dmg, zip, pkg or tar.gz, reads `CFBundleIconFile` from `Info.plist`, and converts the `.icns` file to 128 and 256 px PNGs with `sips`. It writes `manifest.json` with the source URL, version and SHA-256 of each icon. For tar.gz files the script refuses unsafe paths and link entries among the files it extracts.

Some apps, such as those that keep their icon in an asset catalog, set no usable `CFBundleIconFile`. For these the script falls back to `qlmanage -t`, which renders the bundle's icon as a 512 px thumbnail, and then scales that with `sips`. The thumbnail is the icon macOS shows for the app, so the result matches what users know.

The website build reads the catalog and fails when an app lacks `public/icons/<token>-128.png` or `-256.png`.

### Consequences

* Good, because adding a catalog app takes one script run and the manifest records its source.
* Good, because the build fails before a page ships with a missing icon.
* Bad, because the script runs only on macOS, since it needs `sips`, `plutil` and `qlmanage`.
* Bad, because a vendor server that is down blocks the run for its app. Rerun the script for that token later.
* Bad, because a `qlmanage` thumbnail may include system framing that a direct `.icns` render does not.
