---
status: accepted
date: 2026-11-24
---
# 0020. Catalog generator in Node under catalog

Accepted by default, not reviewed by the owner.

## Context and problem statement

[ADR-0015](0015-settlein-publishes-its-own-catalog-file.md) says a scheduled job builds the catalog file from Homebrew. The ADRs leave open the script language and where the source list, the script and the generated file live. The website is Astro ([ADR-0016](0016-astro-for-the-website.md)), so it already needs Node.

## Considered options

* A Node script with no dependencies, with the source list, script and generated file in `catalog/`
* A Python standard-library script
* A TypeScript script that needs a build step

## Decision outcome

Chosen option: "A Node script with no dependencies, with the source list, script and generated file in `catalog/`", because the site and the scheduled job both have Node, and the script needs only the built-in `fetch`.

`catalog/apps.json` is the hand-curated list of name, category and Homebrew cask token. `catalog/generate.mjs` reads each cask from `https://formulae.brew.sh/api/cask/<token>.json` and writes `catalog/catalog.json`. The job runs `node catalog/generate.mjs`. The website build and the deploy step publish `catalog/catalog.json` at `settlein.dev/catalog.json`, which is where the Mac app reads it.

### Consequences

* Good, because the generator adds no package to install and no build step.
* Good, because the generator writes nothing when any entry breaks a rule, so the last good file stays.
* Bad, because the site build must copy the file into its output, and nothing does that yet.
* Bad, because leftover paths can hold wildcards and system paths under `/Library`, so the uninstall work must review them before any delete code runs.
