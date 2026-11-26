---
status: accepted
date: 2026-11-25
---
# 0040. The after-download page checks the download itself

Accepted by default, not reviewed by the owner.

## Context and problem statement

The Download button must show W3 ("Your download has started.") and, when the download does not start, the error state (C41). The disk image is served at `/dl?apps=` (ADR-0018, built in #12), and a response with `Content-Disposition: attachment` leaves the browser on the page that started it. So `/dl` cannot also be the W3 page, and the site needs a way to know whether the download started.

## Considered options

* W3 at its own path `/started?apps=`, which runs a HEAD request to `/dl?apps=` with a 10 second timeout, then starts the download with a hidden link
* W3 at `/dl?apps=`, which would collide with the disk image path
* The home page runs the HEAD check before navigating, and stays put on failure

## Decision outcome

Chosen option: "W3 at its own path", because the error state, Try again and Download again all need one page that holds the selection in its address, and a browser download never shows a page.

The home page Download button goes to `/started?apps=a,b,c`. The page reads the apps from the address, drops tokens the catalog does not list, and sends a person with no valid apps to the home page. It sends `HEAD /dl?apps=...` with `cache: "no-store"` and `AbortSignal.timeout(10000)`. A 2xx response starts the download through a hidden link and shows W3. A network failure, a timeout or any other status shows the error, which names settlein.dev and offers Try again only (grill Q12). Try again and Download again repeat the same check. The address never changes, so the selection survives.

### Consequences

* Good, because the same check serves the first load, Try again and Download again.
* Good, because the page needs no server code and works with the static `/dl` file from #12.
* Bad, because a slow network shows a blank page for up to 10 seconds before the result.
* Bad, because a server that answers HEAD but fails the later GET shows W3 for a download that did not start.
* Bad, because the site now has one more public path, `/started`.
