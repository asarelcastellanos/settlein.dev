---
status: accepted
date: 2026-11-25
---
# 0041. App fetches catalog icons from settlein.dev

## Context and problem statement

Pick apps and the installed list show letter tiles, because the 44 icons are bundled only in the website (ADR-0026, `website/public/icons/`). The app needs real icons, and the catalog grows without an app release.

## Considered options

* Fetch each icon from settlein.dev and cache it on disk
* Bundle the icons in the app
* Keep letter tiles

## Decision outcome

Chosen option: "Fetch each icon from settlein.dev", because new catalog apps get icons without an app update and C5 holds.

The app requests `https://settlein.dev/icons/<token>-256.png`, the path the website serves, where the token is the Homebrew cask token. It caches the file in `~/Library/Caches/SettleIn/icons`. A letter tile shows while the icon loads, when the Mac is offline, and when the icon is missing. Every request uses the ephemeral session of ADR-0029, with no cookies and the User-Agent SettleIn, and redirects stay on settlein.dev, so C5 and C27 hold.

Debug builds take `-iconBase`, a folder of icon files, in the style of `-catalogFile` (ADR-0024, ADR-0040). With it the app reads that folder and skips the network and the cache. Release builds ignore it.

### Consequences

* Good, because a new catalog app shows its icon once the site serves the file.
* Good, because the app binary carries no vendor trademarks.
* Bad, because settlein.dev serves no icons yet, so Release builds show letter tiles until the site is live.
* Bad, because a changed icon stays stale in the cache until the cache is cleared.
