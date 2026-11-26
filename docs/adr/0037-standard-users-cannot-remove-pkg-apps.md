---
status: accepted
date: 2026-11-25
---
# 0037. Standard users cannot remove pkg apps

## Context and problem statement

C30 asks for the admin password once through a macOS prompt when a person removes a pkg app. A standard user cannot complete that prompt without an administrator nearby. The handoff's proposal 24 shows an explanation instead.

## Considered options

* Show a panel saying an administrator must remove the app, with no password prompt
* Show the macOS prompt anyway, so an administrator can type their name and password

## Decision outcome

Chosen option: "Show the explanation", because the owner chose it (grill 2026-11-25, Q3). Admin users still get the one prompt from C30. Copy apps in `~/Applications` stay removable by the standard user.

### Consequences

* Good, because a standard user never sees a prompt they cannot complete.
* Bad, because an administrator who is present cannot remove the app from the standard user's session and must log in themselves.
