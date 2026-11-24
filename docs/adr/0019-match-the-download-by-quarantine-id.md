---
status: accepted
date: 2026-11-24
---
# 0019. Match the download by its quarantine event ID

## Context and problem statement

ADR-0018 puts the selection in the download URL that macOS stores on `Settlein.dmg`. When the person opens Settlein from the mounted disk image, the app finds that image through the mount and reads the URL. The test build (issue #3) showed that an app copied out of the image into another folder cannot find its image through the mount. The copy still carries the same quarantine event ID as the `Settlein.dmg` it came from.

## Considered options

* Match the copy's quarantine event ID against `Settlein.dmg` files in Downloads
* Read the newest `Settlein.dmg` in Downloads
* Ask the person to open the downloaded `Settlein.dmg`

## Decision outcome

Chosen option: "Match the copy's quarantine event ID", because it names the exact download with no guessing.

The app looks for its image through the mount first. If the app runs from outside a disk image, it reads the event ID from its own `com.apple.quarantine` attribute. It then picks the `Settlein.dmg` or `Settlein (N).dmg` in Downloads with the same event ID, and reads the selection from that file's `kMDItemWhereFroms[0]`. If no file matches, the app shows no selection and does not guess.

### Consequences

* Good, because a person who drags Settlein out of the image still gets their selection.
* Good, because an older download with a different selection is never picked.
* Bad, because the quarantine attribute format is not documented by Apple. The test build read it on macOS 27.2.1 only.
* Bad, because a person who deletes the DMG before opening the copy gets no selection.
