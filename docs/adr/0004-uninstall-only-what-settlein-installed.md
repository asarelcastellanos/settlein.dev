---
status: accepted
date: 2026-11-24
---
# 0004. Uninstall only what Settlein installed

## Context and problem statement

The owner wants Settlein to remove apps as well as install them. A general uninstaller guesses which files belong to an app, and a wrong guess deletes a person's data. Settlein has exact knowledge only of the apps it installed and of the leftover paths its catalog lists for them.

## Considered options

* Remove apps Settlein installed, with their support files
* Remove any app on the Mac, with its support files
* Move the app bundle to the Trash and leave support files

## Decision outcome

Chosen option: "Remove apps Settlein installed, with their support files", because Settlein then deletes only paths the catalog names for an app it put on the Mac.

### Consequences

* Good, because removal is predictable and testable per catalog app.
* Bad, because Settlein must keep a record of what it installed, and that record is lost if the person deletes Settlein's data.
* Bad, because an app the person installed by hand cannot be removed through Settlein, even when the catalog lists it.
* Bad, because macOS 13 and later require the person to grant the App Management permission in System Settings before Settlein may remove another app.
