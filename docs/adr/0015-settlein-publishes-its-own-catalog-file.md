---
status: accepted
date: 2026-11-24
---
# 0015. Settlein publishes its own catalog file

## Context and problem statement

The catalog is a curated subset of Homebrew Cask ([ADR-0003](0003-curated-catalog-on-homebrew-cask-data.md)). Homebrew's full file is about 19.5 MB and its format can change without notice. The website and the app both need the same view of each app.

## Considered options

* A scheduled job builds a small Settlein catalog file from Homebrew once a day, and the site and the app read only that file
* The app and the site call Homebrew's API directly
* A catalog file written by hand into each release

## Decision outcome

Chosen option: "A scheduled job builds a small Settlein catalog file from Homebrew once a day", because a change or outage at Homebrew then breaks one job instead of every installed app.

### Consequences

* Good, because the app downloads a file of a few kilobytes from settlein.dev and never contacts Homebrew.
* Good, because the job can refuse an entry that breaks Settlein's rules before anyone installs it.
* Bad, because a vendor release can be up to a day ahead of the catalog. A stale checksum then fails that app's install until the next run.
* Bad, because the scheduled job is a piece of infrastructure that can fail silently.
