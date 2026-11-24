---
status: accepted
date: 2026-11-24
---
# 0021. Uninstall never touches user file folders

## Context and problem statement

The catalog takes each app's leftover paths from its Homebrew cask `zap` stanza. Some stanzas list folders that hold the person's own files. Zoom lists `~/Documents/Zoom` and `~/Desktop/Zoom`, where it saves recordings, and Audacity lists `~/Documents/Audacity4`. ADR-0004 says a wrong guess deletes a person's data.

## Considered options

* Drop leftover paths under user file folders from the catalog
* Keep them, mark them as user files, and ask before removing each one
* Remove them like any other leftover path

## Decision outcome

Chosen option: "Drop leftover paths under user file folders from the catalog", because uninstalling an app must never cost the person their files.

The catalog generator leaves out every leftover path under `~/Desktop`, `~/Documents`, `~/Downloads`, `~/Movies`, `~/Music`, `~/Pictures` and `~/.config`. It prints each path it leaves out. Uninstall removes only what the catalog lists, as C31 says, so these folders stay.

### Consequences

* Good, because recordings, projects and config files survive an uninstall.
* Bad, because some app-made folders in those locations stay behind after uninstall.
