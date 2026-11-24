---
status: accepted
date: 2026-11-24
---
# 0011. Signature always, checksum when present

## Context and problem statement

Settlein downloads apps from vendor links and installs them with one confirmation. macapps.link runs no check on what it downloads. Homebrew gives a SHA-256 checksum for most apps, but not for apps whose vendor reuses one link for every release.

## Considered options

* Require a valid Developer ID signature and notarization for every app, and a matching checksum when Homebrew gives one
* Require both for every app
* Trust the checksum alone

## Decision outcome

Chosen option: "Require a valid Developer ID signature and notarization for every app, and a matching checksum when Homebrew gives one", because the signature check covers every app, including the ones with a fixed download link.

### Consequences

* Good, because a tampered or unsigned download is refused before it reaches the Applications folder.
* Good, because Settlein keeps quarantine on what it installs, so Gatekeeper checks each app again on first open.
* Bad, because an app that is not notarized can never be listed.
* Bad, because an app without a checksum relies on the signature alone, and the catalog should record the expected developer team per app to make that check specific.
