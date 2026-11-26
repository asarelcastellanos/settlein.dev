---
status: accepted
date: 2026-11-25
---
# 0039. Website and app are light only

## Context and problem statement

C10 made the website follow the system light or dark appearance, and the design brief asked for light and dark tokens. The handoff's decisions 4, 16 and 27 ship light only. Dark values exist in DESIGN.md but are reserved.

## Considered options

* Light only, with the Mac app forced to light through `.preferredColorScheme(.light)` on the root view
* Follow the system appearance with the reserved dark values

## Decision outcome

Chosen option: "Light only", because the owner decided it in the handoff (decisions 4 and 16). C10 is replaced. Dark mode can come later from the reserved tokens.

### Consequences

* Good, because each screen is built and checked once.
* Bad, because people who run macOS in dark mode get a bright window and page.
