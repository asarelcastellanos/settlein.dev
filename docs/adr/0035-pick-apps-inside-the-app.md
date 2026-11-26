---
status: accepted
date: 2026-11-25
---
# 0035. Pick apps inside the app

Supersedes [ADR-0027](0027-settlein-opens-to-the-installed-list.md).
Supersedes [ADR-0006](0006-website-is-the-only-catalog-interface.md).

## Context and problem statement

C16 sent a launch with no selection and nothing installed to settlein.dev in the browser, and ADR-0027 opened the installed list otherwise, with a button to the website. The handoff's decisions 19 and 20 add a picker inside the app (screen A7) with the website picker's layout. Adding apps then no longer needs the browser.

## Considered options

* An in-app picker, with launch logic: a selection goes to Installing, no selection and nothing installed goes to Pick apps, anything else goes to the installed list
* Keep the browser hand-off from C16 and ADR-0027

## Decision outcome

Chosen option: "An in-app picker", because the owner decided it in the handoff (decisions 19 and 20). A7 opens from Add apps on the installed list, from Change selection, and on a launch with no selection and nothing installed. Installed apps show as installed and cannot be ticked. The bar says "Install N apps".

### Consequences

* Good, because a person can add apps later without the website.
* Good, because already installed apps (C25) are visible before installing.
* Bad, because the picker exists twice, in Astro and in SwiftUI, and both must follow the same catalog and design.
