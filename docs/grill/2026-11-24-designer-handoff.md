# Grill: designer handoff

2026-11-24, issue-sized, one round in the main session with AskUserQuestion.

## Scope

| Question | Answer |
|---|---|
| What is the ask? | "can we first follow our studio201 steps where we build a blueprint or simple wireframe and create a detailed doc and explination so our designer can go off and understand the whole project and design a finalized website and mac app ?" |
| Does building wait for the designs? | No. "that way we can continue building and once the finalized designs are back we can have a branch just for that." |
| Size | Issue-sized. One package of docs and wireframes, with no spec claim changed. |
| Studio 201 mode | new, saved in `.studio/config.json` by PR #52. |

## Round 1

| # | Question | Answer |
|---|---|---|
| Q1 | Which surfaces does the package cover? | Website catalog page, Mac app screens, App icon and wordmark, DMG window and first open. |
| Q2 | What form do the wireframes take? | Grey-box HTML pages in `docs/design/`, one page per screen and state, also published as a private link to send the designer. |
| Q3 | What does the designer return, and how much layout freedom do they get? | Figma plus DESIGN.md, layout open. Content, states and spec rules are fixed. Layout, type, color and motion are the designer's call. The designer returns Figma screens and a DESIGN.md with light and dark tokens that the ui-builder builds from. [ADR-0023](../adr/0023-designer-returns-figma-and-design-md.md) |
