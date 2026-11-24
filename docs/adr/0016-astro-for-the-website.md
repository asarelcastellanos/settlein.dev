---
status: accepted
date: 2026-11-24
---
# 0016. Astro for the website

## Context and problem statement

The website is one page that renders the catalog, tracks ticked apps in the page address and starts the download. It deploys to Cloudflare Pages ([ADR-0012](0012-cloudflare-pages-hosting.md)).

## Considered options

* Astro
* Hand-written HTML, CSS and JavaScript with no build step
* Next.js

## Decision outcome

Chosen option: "Astro", because it renders the catalog to static HTML at build time and ships only the small script the checklist needs.

### Consequences

* Good, because the page works before any script loads and deploys to Cloudflare Pages with an official adapter.
* Bad, because the site needs Node and a build step.
* Bad, because the catalog page must rebuild when the catalog file changes.
