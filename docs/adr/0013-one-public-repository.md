---
status: accepted
date: 2026-11-24
---
# 0013. One public repository

## Context and problem statement

Settlein has three parts that change together. They are the website, the Mac app and the catalog. The project is open source ([ADR-0007](0007-free-and-open-source.md)).

## Considered options

* One public repository named `settlein.dev` under the owner's GitHub account, with an MIT licence
* One private repository made public at release
* Separate repositories for the site, the app and the catalog

## Decision outcome

Chosen option: "One public repository named `settlein.dev`", because a change to the catalog format reaches the site and the app in one pull request.

### Consequences

* Good, because issues, releases and the branch flow live in one place.
* Bad, because unfinished work is public from the first commit.
* Bad, because one repository holds a Swift project and a web project, so its checks must run two toolchains.
