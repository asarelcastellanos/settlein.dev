---
status: accepted
date: 2026-11-24
---
# 0010. Admin password to remove pkg apps

## Context and problem statement

A `.pkg` can put files outside the home folder, such as launch daemons and privileged helper tools. Removing them needs root. Settlein installs without root ([ADR-0005](0005-copy-apps-and-open-pkg-installers.md)), so a complete uninstall of a `.pkg` app needs a separate decision.

## Considered options

* Run the removal as root after one macOS admin password prompt
* Remove what Settlein can reach and list the rest for the person
* Offer no uninstall for `.pkg` apps

## Decision outcome

Chosen option: "Run the removal as root after one macOS admin password prompt", because the owner wants uninstall to leave nothing behind.

### Consequences

* Good, because a `.pkg` app is removed completely, including its system files.
* Bad, because Settlein runs privileged code, and a wrong path in the catalog's removal data could delete system files. The spec must limit the root step to paths listed for that app and reviewed per catalog entry.
* Bad, because a standard user without an admin password cannot uninstall these apps.
* Bad, because system extensions and kernel extensions may still need the vendor's own uninstaller.
