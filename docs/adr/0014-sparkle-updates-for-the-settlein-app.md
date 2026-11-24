---
status: accepted
date: 2026-11-24
---
# 0014. Sparkle updates for the Settlein app

## Context and problem statement

The Settlein app stays on the Mac so it can uninstall later ([ADR-0004](0004-uninstall-only-what-settlein-installed.md)). An installer with a known bug keeps running on people's Macs unless it can replace itself. The app is distributed outside the Mac App Store, so Apple does not update it.

## Considered options

* Automatic updates with Sparkle
* A notice on launch that links to the download
* No update mechanism in the first version

## Decision outcome

Chosen option: "Automatic updates with Sparkle", because a fix to the installer reaches every Mac without the person downloading Settlein again.

### Consequences

* Good, because security fixes to Settlein ship to existing installs.
* Bad, because Sparkle is the app's first third-party dependency.
* Bad, because the owner must keep an EdDSA signing key safe. Losing it ends updates for existing installs.
* Bad, because each release must publish a signed appcast feed alongside the notarized build.
