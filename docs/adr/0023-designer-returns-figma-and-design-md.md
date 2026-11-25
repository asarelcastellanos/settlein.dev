---
status: accepted
date: 2026-11-24
---
# 0023. Designer returns Figma and DESIGN.md

## Context and problem statement

An outside designer will design the Settlein website, the Mac app screens, the app icon and wordmark, and the DMG window. Building continues while they work, so the build uses neutral styling until the designs come back. The design branch must turn the designs into code without a second round of interpretation. The handoff has to fix what the spec already decides and leave the rest to the designer.

## Considered options

* Figma screens plus a DESIGN.md with light and dark tokens, with layout open to the designer
* Figma screens only, with the wireframe layout fixed
* Finished HTML and CSS for the website from the designer

## Decision outcome

Chosen option: "Figma screens plus a DESIGN.md with light and dark tokens, with layout open to the designer", because the ui-builder agent builds from DESIGN.md, and the spec fixes content and behaviour, not layout.

The handoff package fixes content, states and spec rules. The designer decides layout, type, color and motion. The wireframes in `docs/design/` are a starting point, not the layout.

### Consequences

* Good, because the design branch reads tokens from one file for both the website and the SwiftUI app.
* Good, because the designer can change layout without a new spec claim, as long as every claim still holds.
* Bad, because a layout that departs from the wireframes can conflict with code built in the meantime, and the design branch then reworks it.
* Bad, because the designer must write DESIGN.md in the token format the ui-builder expects, which the brief has to spell out.
