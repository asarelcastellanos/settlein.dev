---
status: accepted
date: 2026-11-24
---
# 0028. Release script signs after an unsigned build

Accepted by default, not reviewed by the owner.

## Context and problem statement

Issue #16 needs a signed, notarized app and disk image from the XcodeGen project in `app/`. The project sets `CODE_SIGN_IDENTITY: "-"` for development. Signing could happen inside xcodebuild or after it.

## Considered options

* Pass the Developer ID to xcodebuild and let it sign
* Build with signing off, then sign with `codesign` in the release script

## Decision outcome

Chosen option: "Build with signing off, then sign with codesign", because `test-build/build.sh` already proved those exact `codesign`, `notarytool` and `stapler` steps, and the project file stays free of the owner's identity. `scripts/release.sh` copies the source into a temporary folder, generates and builds Release there, and writes `Settlein.app` and `Settlein.dmg` into the output folder only after every step passes.

### Consequences

* Good, because the identity and notary profile are script inputs and never enter the repository.
* Good, because a failed step leaves no partial output.
* Bad, because the release path differs from a Debug build in Xcode.
