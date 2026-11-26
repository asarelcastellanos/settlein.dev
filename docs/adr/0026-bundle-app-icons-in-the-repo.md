---
status: accepted
date: 2026-11-24
---
# 0026. Bundle app icons in the repo

## Context and problem statement

Claim C6 shows every catalog app as an icon with its name. The catalog page uses letter tiles for now, and the catalog file has no icon field. The site promises no ads, no cookie and cookieless analytics (C11, C13), so every outside request costs privacy.

## Considered options

* Bundle one icon file per catalog app in the repo and serve it from settlein.dev
* Load each icon from the vendor's site or a third-party icon service
* Keep letter tiles

## Decision outcome

Chosen option: "Bundle one icon file per catalog app in the repo", because the page then makes no request outside settlein.dev and works the same when a vendor moves its files.

### Consequences

* Good, because the page loads every icon from its own host.
* Good, because the designer's restyle (ADR-0023) can size and frame the icons with no outside dependency.
* Bad, because the repo holds 44 vendor icons, and each new catalog app needs its icon added by hand or by a script.
* Bad, because vendor icons are trademarks. Settlein shows them only to identify the app, and the source of each file must be recorded.
