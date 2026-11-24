---
status: accepted
date: 2026-11-24
---
# 0018. The download link carries the selection, and the file name does not

Supersedes [ADR-0002](0002-download-carries-the-selection.md).

## Context and problem statement

ADR-0002 lets the Settlein download carry the ticked apps, in the file name or in the origin URL the browser stores on the file. The first test build named the file after the selection, for example `Settlein-firefox,raycast,vlc.dmg`. The owner does not want the app names visible on the file in Downloads or in Finder.

## Considered options

* A plain file name, with the selection only in the download URL
* An opaque code in the file name and the URL, which the app decodes
* A short code stored on the server, which the app fetches

## Decision outcome

Chosen option: "A plain file name, with the selection only in the download URL", because the file reads `Settlein.dmg` and the site stores nothing.

The website serves every download as `Settlein.dmg`. The download URL holds the selection in its query string, for example `https://settlein.dev/dl?apps=firefox,raycast`. The app reads the selection from the file's `kMDItemWhereFroms` attribute only.

### Consequences

* Good, because the file name in Downloads and on the mounted volume names no apps.
* Good, because no account and no server-side session is needed, as in ADR-0009.
* Bad, because Finder's Get Info still shows the download URL with the app names under "Where from".
* Bad, because the file name is no longer a second carrier. If a browser drops the where-from attribute, the app has no selection, and the fallback in the plan applies.
