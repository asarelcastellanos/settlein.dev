---
status: accepted
date: 2026-11-25
---
# 0038. Rename the app to SettleIn with a capital I

## Context and problem statement

The handoff's decision 1 names the product SettleIn everywhere, including the wordmark and `SettleIn.dmg`. The code uses Settlein, with the bundle ID `dev.settlein.Settlein`. A bundle ID cannot change after release without breaking Sparkle updates and saved settings. Nothing has shipped yet.

## Considered options

* Rename the display name, product name, disk image and bundle ID, with bundle ID `dev.settlein.SettleIn`
* Rename only the display name and keep `dev.settlein.Settlein`

## Decision outcome

Chosen option: "Rename everything", because the owner chose it (grill 2026-11-25, Q10). The domain stays `settlein.dev`, and the repository keeps its name.

### Consequences

* Good, because the name, file names and identifier match.
* Bad, because the docs, scripts and spec that say Settlein need a rename pass.
