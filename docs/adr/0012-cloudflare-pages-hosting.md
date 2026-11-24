---
status: accepted
date: 2026-11-24
---
# 0012. Cloudflare Pages hosting

## Context and problem statement

The website is static. The handoff ([ADR-0002](0002-download-carries-the-selection.md)) may need one server function that names the download file after the selection. The site also serves the Settlein app download, so bandwidth cost matters. The owner wants privacy-first analytics on the website only.

## Considered options

* Cloudflare Pages
* GitHub Pages
* Vercel

## Decision outcome

Chosen option: "Cloudflare Pages", because it serves static files and edge functions for free with no bandwidth charge, and its cookieless Web Analytics meets the analytics answer.

### Consequences

* Good, because both handoff carriers stay possible.
* Good, because analytics needs no cookie banner and the app sends nothing.
* Bad, because the site depends on a Cloudflare account and the domain must point at Cloudflare.
* Bad, because edge functions tie the download step to Cloudflare's runtime.
