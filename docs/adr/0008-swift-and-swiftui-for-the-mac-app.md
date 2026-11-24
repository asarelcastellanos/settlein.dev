---
status: accepted
date: 2026-11-24
---
# 0008. Swift and SwiftUI for the Mac app

## Context and problem statement

The Mac app verifies code signatures, sets quarantine on downloads, copies bundles into the Applications folder and handles macOS permissions. It is the first thing a person downloads on a new Mac, so its size and first launch matter.

## Considered options

* Swift and SwiftUI
* Tauri
* Electron

## Decision outcome

Chosen option: "Swift and SwiftUI", because the security and file APIs the app needs are native Swift calls, and the download stays at a few megabytes.

### Consequences

* Good, because the app calls the Security framework and file APIs with no bridge.
* Bad, because the app shares no interface code with the website.
* Bad, because building, signing and notarizing need a Mac with Xcode.
