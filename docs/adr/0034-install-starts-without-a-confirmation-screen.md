---
status: accepted
date: 2026-11-25
---
# 0034. Install starts without a confirmation screen

## Context and problem statement

C18 made SettleIn download nothing until the person approved a confirmation screen listing the selection. The handoff's decision 17 removes that screen. The person already picked the apps on settlein.dev or in the app, so a second approval repeats the choice. Without approval, an unexpected selection installs at once, so the selection's origin matters more.

## Considered options

* Start installing as soon as SettleIn opens with a selection, with Cancel and Change selection always on the Installing screen
* Keep the confirmation screen from C18
* Show the selection for a few seconds with a countdown, then start

## Decision outcome

Chosen option: "Start installing at once", because the owner decided it in the handoff (decision 17). The selection still comes only from the downloaded disk image or a settlein.dev link, and every download still passes the signature, notarization and checksum checks (C22, C23). Cancel lets the app in progress finish, skips the rest and keeps what is installed. Change selection lets the app in progress finish, then opens Pick apps with the same apps ticked.

### Consequences

* Good, because setup needs one click less.
* Good, because the checks that refuse bad downloads are unchanged.
* Bad, because a link someone else sent starts installing before the person sees the list. Every app is still a catalog app that the owner approved.
* Bad, because claims C15, C17, C18 and C19 and the confirmation screen built in #9 have to change.
