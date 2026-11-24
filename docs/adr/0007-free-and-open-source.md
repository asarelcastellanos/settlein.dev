---
status: accepted
date: 2026-11-24
---
# 0007. Free and open source

## Context and problem statement

Settlein installs software on a person's Mac, so the person has to trust it. The owner wants no ads. The catalog data comes from Homebrew, whose API states no terms for commercial reuse.

## Considered options

* Free and open source
* Free, closed source
* Paid

## Decision outcome

Chosen option: "Free and open source", because anyone can read what the installer does, and a free product avoids the open question about commercial use of Homebrew's data.

### Consequences

* Good, because people can audit the app and propose catalog entries.
* Bad, because the owner pays the Apple Developer Program fee and hosting with no income from the product.
* Bad, because a public repo brings issues and pull requests to triage.
