---
status: accepted
date: 2026-11-24
---
# 0005. Copy apps and open pkg installers

## Context and problem statement

Most catalog apps install by copying one `.app` bundle into the Applications folder. Some ship a `.pkg` installer, which needs root. The supported way for Settlein to run a `.pkg` unattended is a privileged daemon that the person approves in System Settings.

## Considered options

* Copy `.app` bundles, and open each `.pkg` in Apple's Installer for the person
* Install only copy-to-Applications apps
* Install both unattended through a privileged helper

## Decision outcome

Chosen option: "Copy `.app` bundles, and open each `.pkg` in Apple's Installer for the person", because the catalog can hold apps such as Zoom without Settlein running any code as root during an install.

### Consequences

* Good, because installing needs no privileged helper and no admin password typed into Settlein.
* Good, because Settlein still downloads and verifies the `.pkg` before the person sees it.
* Bad, because `.pkg` apps are not hands-free. The person clicks through Apple's Installer once per app.
* Bad, because Settlein cannot tell from Apple's Installer whether the person finished or cancelled, so it must check the result itself.
