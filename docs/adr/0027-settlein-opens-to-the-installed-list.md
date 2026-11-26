---
status: superseded by [ADR-0035](0035-pick-apps-inside-the-app.md)
date: 2026-11-24
---
# 0027. Settlein opens to the installed list

## Context and problem statement

Claim C16 sends a launch of Settlein with no selection to settlein.dev (grill Q8). Claim C28 needs a list of the apps Settlein installed, with an uninstall control for each. With C16 as written, the app has no way for a person to reach that list on their own. The design brief raised this as an open question.

## Considered options

* With no selection, Settlein shows the installed list when it has installed anything, and opens settlein.dev only when it has installed nothing
* Keep C16, and let a "Manage installed apps" link on the website open Settlein by its link scheme
* Keep C16, and add a menu bar item after the first install

## Decision outcome

Chosen option: "Settlein shows the installed list when it has installed anything", because a person who wants to remove an app opens Settlein from Applications and expects to land in it.

The installed list has an "Add apps" button that opens settlein.dev. The website stays the only place to choose new apps (ADR-0006). C16 now applies only when Settlein has installed nothing.

### Consequences

* Good, because uninstalling starts in the app, with no browser step.
* Good, because a first launch on a new Mac still sends the person to the website, as grill Q8 asked.
* Bad, because C16 changes after the spec was approved, so its QA proof needs a Mac user account where Settlein has installed nothing.
* Bad, because the app must read its record of installed apps at every launch to choose the screen.
