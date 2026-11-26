---
status: accepted
date: 2026-11-24
---
# 0030. Pkg install pipeline


## Context and problem statement

Issue #11 opens pkg installers in Apple's Installer (ADR-0005). The spec fixes the order (C21, S5) but not how Settlein finds the package in a download, which checks prove the package, or how long the opened package lives.

## Considered options

* Verify with `pkgutil --check-signature` and `spctl -a -t install`, then open with `NSWorkspace` and keep the package in a temporary folder that the next run cleans
* Verify with the Security framework only
* Run `installer` as root

## Decision outcome

Chosen option: "pkgutil and spctl, then NSWorkspace", because the Security framework checks code signatures on bundles and the package tools are the supported way to read a package signature and its notarization.

The download passes the same downloader and SHA-256 checks as copy apps. A file starting with `xar!` is a package. A zip is unpacked with `ditto`. Anything else is attached read-only with `hdiutil`. A zip or disk image must hold exactly one regular `.pkg` at its top level, or Settlein refuses it. Google Drive ships its package inside a disk image, so this path is required.

The package passes only if `pkgutil --check-signature` exits 0 and reports a Developer ID Installer certificate and "Notarization: trusted by the Apple notary service", and `spctl -a -t install -vv` exits 0 with `source=Notarized Developer ID`. A failure refuses that app with a reason and the run continues.

Settlein then sets the quarantine attribute on the package (S6), moves it to `settlein-pkg-<uuid>` in the temporary folder, and opens it with `NSWorkspace.open(_:withApplicationAt:configuration:)` on `/System/Library/CoreServices/Installer.app`. Settlein never runs `installer` and shows no password prompt.

The opened package must stay readable while the person works in Installer, so it is not removed on success. Settlein removes `settlein-pkg-*` folders older than 24 hours when the next run starts, and macOS clears the temporary folder on its own schedule. If the open fails, Settlein removes the folder at once.

### Consequences

* Good, because Settlein runs nothing as root and a refused package never reaches Installer.
* Good, because the quarantine attribute stays, so Gatekeeper checks the package again when Installer opens it.
* Bad, because a verified package may stay on disk for up to a day after the person finishes.
* Bad, because the check relies on `pkgutil` output text, which Apple can reword.
* Bad, because a download with more than one package is refused.
