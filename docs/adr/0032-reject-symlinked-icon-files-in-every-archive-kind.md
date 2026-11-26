---
status: accepted
date: 2026-11-25
---
# 0032. Reject symlinked icon files in every archive kind

Accepted by default, not reviewed by the owner.

## Context and problem statement

ADR-0031 makes `scripts/extract-icons.mjs` refuse link entries in tar.gz files, because vendor archives are untrusted. Zip, dmg and pkg content has no such check. An app bundle in one of these can hold `Contents/Info.plist` or an `.icns` file that is a symlink to a local image. The script then reads the local file and commits it as an icon.

## Considered options

* Check links at extraction, once for each archive kind
* Check the two files the script reads, after the bundle is found, whatever the archive kind
* Leave zip, dmg and pkg unchecked

## Decision outcome

Chosen option: "Check the two files the script reads", because one check covers every archive kind, including a tar.gz that holds a bundle, and it guards exactly what reaches `plutil` and `sips`.

This extends ADR-0031. It does not change it. Before the script reads `Info.plist` or the icon file, it walks each path component below the `.app` with `lstat`. It fails the app if any component is a symlink. It then resolves the path with `realpath` and fails the app if the result is outside the real path of the `.app`. The failure message names the file and the app. A file that does not exist is not an error, so the existing `qlmanage` fallback still applies.

### Consequences

* Good, because a local file cannot become an icon through a link in any archive kind.
* Good, because the check is one function that every read of bundle content goes through.
* Bad, because a vendor that ships a legitimate symlinked icon fails until the owner decides how to handle that app.
