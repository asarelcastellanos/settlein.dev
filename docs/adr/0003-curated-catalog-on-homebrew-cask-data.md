---
status: accepted
date: 2026-11-24
---
# 0003. Curated catalog on Homebrew Cask data

## Context and problem statement

Settlein needs a list of apps with a current download link, version and checksum for each. Vendors change links with every release, and macapps.link shows what happens when nobody updates them. Homebrew Cask publishes this data for several thousand apps through a public JSON API.

## Considered options

* A curated list whose download data comes from Homebrew Cask
* All of Homebrew Cask with search
* A catalog maintained fully by hand

## Decision outcome

Chosen option: "A curated list whose download data comes from Homebrew Cask", because the owner chooses which apps appear while Homebrew's contributors keep links, versions and checksums current.

### Consequences

* Good, because Settlein can test every app it lists.
* Good, because the person never installs or sees Homebrew.
* Bad, because Settlein depends on an API with no stated terms for its data. The repo code is BSD 2-Clause.
* Bad, because a cask with `sha256 :no_check` gives no checksum, so Settlein needs its own rule for those apps.
* Bad, because an app missing from Homebrew Cask cannot be listed without a second data source.
