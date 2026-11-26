---
status: accepted
date: 2026-11-25
---
# 0040. Install record and launch inputs

Accepted by default, not reviewed by the owner.

## Context and problem statement

The launch logic (C16, ADR-0035) and the installed list (C28) need to know which apps SettleIn installed. The spec names no store for that. No earlier issue wrote one, and the uninstall issue (#14) reads it. The handoff (A4) sketches a JSON file in Application Support with a rename to `installs.damaged.json` when the file cannot be decoded.

## Considered options

* A JSON file `installs.json` in `~/Library/Application Support/SettleIn`, written by the app after each run for the apps that finished, with a Debug-only `-recordFile` argument beside `-catalogFile` and `-selection`
* Scan the Applications folders for catalog apps
* A store in `UserDefaults`

## Decision outcome

Chosen option: "A JSON file", because a scan would list apps installed by hand, which C28 forbids, and the handoff describes the file.

Each entry holds the catalog token, the installer type and the date. A missing file means nothing installed. A file that cannot be read or decoded moves to `installs.damaged.json`, and the installed list shows the "Can't read the list" state. Try again then runs the launch logic against the fresh record. The list shows an entry only when the catalog still holds the app and its bundles are still in an Applications folder. Pkg apps are recorded once SettleIn opens them in Apple's Installer, because SettleIn cannot tell whether the person finished. The record is written when a run ends, so quitting mid-run records nothing for that run.

`-recordFile` follows ADR-0024: Debug builds read it and Release builds ignore it, so QA can start from an empty record without touching the real one.

### Consequences

* Good, because the installed list never shows apps installed by hand.
* Good, because uninstall (#14) can remove an entry from the same file.
* Bad, because a run that is quit before it ends leaves its finished apps out of the record.
* Bad, because an app moved out of an Applications folder drops from the list although the record still names it.
