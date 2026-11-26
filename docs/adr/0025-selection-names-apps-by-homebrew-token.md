---
status: accepted
date: 2026-11-24
---
# 0025. The selection names apps by Homebrew token

## Context and problem statement

ADR-0009 puts the selection in the page address, and ADR-0018 carries the same string in the download link. Neither says how an app is named in that string. The catalog page joins `catalog/apps.json` to get each app's Homebrew Cask token, while the app shell's development input matches display names. The website, the handoff and the app must read one format.

## Considered options

* Homebrew Cask tokens, for example `?apps=firefox,visual-studio-code`
* Display names, for example `?apps=Firefox,Visual%20Studio%20Code`
* Short numeric IDs assigned by Settlein

## Decision outcome

Chosen option: "Homebrew Cask tokens", because a token stays the same when a vendor renames an app, needs no URL escaping, and already matches the allowed characters `a-z`, `0-9`, `-` and commas from the test build.

### Consequences

* Good, because one string works in the page address, the download link and the link that opens an installed Settlein.
* Good, because links stay short and readable.
* Bad, because `catalog/catalog.json` has no token field today, so the app cannot match a token without one. The catalog generator must add a `token` field before the handoff issues (#12, #13) read the selection.
* Bad, because a renamed or removed cask token breaks saved links, so the site and the app must ignore unknown tokens without an error.
