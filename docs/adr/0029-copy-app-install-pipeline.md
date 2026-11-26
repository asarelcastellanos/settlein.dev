---
status: accepted
date: 2026-11-24
---
# 0029. Copy app install pipeline


## Context and problem statement

Issue #10 installs copy apps from vendor downloads. The spec fixes the checks (C22, C23, C24) and the folders (C20). It does not say how the app reads a zip or a disk image, where it sets the quarantine attribute, how it picks the folder, or how it keeps requests free of identifiers (C27).

## Considered options

* Sniff the file, unpack zip with `ditto` and disk images with `hdiutil`, verify the staged bundle, set quarantine on it, then move it into place
* Trust the URL extension to pick the unpacker
* Install first and verify in the Applications folder

## Decision outcome

Chosen option: "Sniff the file and verify the staged bundle", because catalog URLs do not reliably end in `.zip` or `.dmg` (Visual Studio Code, HandBrake and WhatsApp have none), and nothing reaches the Applications folder before it passes.

Each app runs in its own temporary folder, removed on success and on failure. A file starting with the zip signature unpacks with `ditto -x -k`. Anything else is attached read-only with `hdiutil attach -nobrowse`, the named bundles are copied out with `ditto`, and the image is detached. A disk image with a license agreement fails to attach and is refused with that reason.

Order per app: download, SHA-256 when the catalog has one, unpack, `SecStaticCodeCheckValidityWithErrors` with the requirement `anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and notarized`, quarantine, move. The quarantine attribute is set on the staged bundle with `URLResourceValues.quarantineProperties` (Apple forum thread 706442, S6), so no bundle is ever in the Applications folder without it. If any bundle of an app fails to move, the ones already moved are removed.

The destination is `/Applications` when the current user can write to it, and `~/Applications` otherwise, so no password prompt appears. A bundle that already exists at the destination is refused and never overwritten.

Every request uses an ephemeral session with no cookies, no credential storage, `User-Agent: Settlein` and `Accept-Language: en`. This replaces the default user agent, which carries the macOS and Darwin versions. Downloads follow only https redirects. The catalog fetch uses the same configuration.

Apps install one at a time, in selection order. A refusal or failure in one app is recorded for that app and the run continues.

### Consequences

* Good, because a refused app leaves nothing behind in the Applications folder or the temporary folder.
* Good, because requests carry nothing that identifies the person or the Mac.
* Bad, because downloads that contain the app inside another archive, such as a zip holding a disk image, are refused with "The download does not hold" until a later issue handles them.
* Bad, because disk images with a license agreement are refused.
* Bad, because the standard-user path was not run on a standard account, only reasoned from `isWritableFile`.
