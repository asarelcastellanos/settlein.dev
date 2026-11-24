---
status: accepted
date: 2026-11-24
---
# 0009. The selection lives in the URL

## Context and problem statement

The owner sets up a new Mac more than once and wants the same apps each time. Other people want to share a setup. Storing lists on a server would need accounts, a database and a privacy policy.

## Considered options

* The page address holds the selection, for example `?apps=firefox,raycast`
* Accounts with saved lists
* No saved selection

## Decision outcome

Chosen option: "The page address holds the selection", because a bookmark or a pasted link restores it with no account and no stored data.

### Consequences

* Good, because the website needs no database and holds no personal data.
* Good, because the same string can feed the handoff.
* Bad, because a long selection makes a long link.
* Bad, because a saved link can name an app the catalog later drops, so the site must handle unknown names.
