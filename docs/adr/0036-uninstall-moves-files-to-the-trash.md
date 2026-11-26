---
status: accepted
date: 2026-11-25
---
# 0036. Uninstall moves files to the Trash

## Context and problem statement

C29 said SettleIn removes the app bundle and every catalog-listed leftover path. A removal cannot be undone. The handoff's proposal 25 moves the files to the Trash instead. C31 still limits uninstall to paths the catalog lists.

## Considered options

* Move the bundle and leftovers to the person's Trash
* Delete them permanently

## Decision outcome

Chosen option: "Move to the Trash", because the owner chose it (grill 2026-11-25, Q4). Copy apps and their leftovers move with `FileManager.trashItem`. For pkg apps, system files owned by root may not move to the person's Trash. The build checks this, and deletes those files only after the admin prompt from C30. The issue records the result.

### Consequences

* Good, because a person who removed the wrong app can put it back from the Trash.
* Bad, because disk space comes back only when the person empties the Trash.
* Bad, because pkg apps may mix moved files and deleted root-owned files.
