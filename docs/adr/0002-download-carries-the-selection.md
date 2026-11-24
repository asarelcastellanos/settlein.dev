---
status: superseded by [ADR-0018](0018-download-link-carries-the-selection.md)
date: 2026-11-24
---
# 0002. The download carries the selection

## Context and problem statement

On a new Mac the Settlein app is not installed, so a `settlein://` link has nothing to open. The website must still tell the app which apps the person ticked. macOS breaks the signature of a notarized app when any file inside it changes, so the selection cannot go inside the app bundle.

## Considered options

* The download carries the selection, as Ninite does on Windows
* A `settlein://` link that opens the app after a separate install
* A short code the person types into the app
* A checklist inside the app, with the website optional

## Decision outcome

Chosen option: "The download carries the selection", because it takes one click and no typing on a Mac that has nothing installed.

### Consequences

* Good, because the person ticks apps, clicks once and opens one file.
* Good, because no account and no server-side session is needed.
* Bad, because the carrier is unproven. The candidates are the download file name and the origin URL that the browser stores on the downloaded file. A spike must test both in Safari and Chrome on current macOS before the spec relies on one.
* Bad, because private browsing and some browsers may drop the carrier, so the app needs a fallback path.
