---
status: accepted
date: 2026-11-24
---
# 0024. App shell structure and development inputs

Accepted by default, not reviewed by the owner.

## Context and problem statement

Issue #9 builds the Mac app shell before the website serves the catalog (#8) and before the handoff delivers a selection (#12, #13). The shell must fetch the catalog only from settlein.dev (C5), yet QA needs a catalog and a selection to see the confirmation screen. An outside designer restyles the screens later (ADR-0023).

## Considered options

* Debug-only launch arguments `-catalogFile` and `-selection`, compiled out of Release builds
* A catalog host setting that any build can change
* A fixture catalog bundled in the app

## Decision outcome

Chosen option: "Debug-only launch arguments", because a Release build then holds no way to read a catalog from anywhere except `https://settlein.dev/catalog.json`, and the handoff issues replace `Selection.current()` without touching the screens.

The project lives in `app/`. `app/project.yml` is the XcodeGen source. `app/Settlein.xcodeproj` is generated from it and not committed, because Xcode writes comments into the generated file and the comment check refuses them. The app targets arm64 on macOS 26.0 and later, with no sandbox, because installing into `/Applications` needs file access the sandbox blocks. The catalog fetch uses an ephemeral session, accepts only status 200, and refuses any redirect to a host other than settlein.dev. `CatalogParser` accepts only the fields the catalog generator writes and refuses the whole catalog on any other field, type or value. Approve ends in the `approved` screen, which records the split between apps to install and apps to skip and downloads nothing. Issue #10 replaces that screen's content with the install run.

### Consequences

* Good, because Release builds cannot be pointed at another host or file.
* Good, because the views take plain values, so a restyle touches `Views.swift` only.
* Bad, because QA can see the confirmation screen only in a Debug build until settlein.dev serves the catalog.
* Bad, because every build needs XcodeGen (`brew install xcodegen`) and one `xcodegen generate` run in `app/` first.
