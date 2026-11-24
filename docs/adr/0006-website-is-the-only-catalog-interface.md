---
status: accepted
date: 2026-11-24
---
# 0006. The website is the only catalog interface

## Context and problem statement

The app can open with no selection, for example after a private-browsing download or months after the first run. It then needs a way to get one. Building a second checklist inside the app would duplicate the website's catalog screen.

## Considered options

* The app opens the website, and the site hands the selection back through a `settlein://` link
* A full checklist inside the app
* A short code typed into the app

## Decision outcome

Chosen option: "The app opens the website, and the site hands the selection back through a `settlein://` link", because the app is installed by then, so the link works, and only one catalog interface exists.

### Consequences

* Good, because the catalog screen is built and maintained once.
* Good, because the same link covers every later run of the app.
* Bad, because choosing apps needs a network connection and a browser.
* Bad, because any web page can call the `settlein://` scheme. The confirmation screen is the guard, and the app must accept only names the catalog knows.
