---
status: accepted
date: 2026-11-25
---
# 0033. Final design handoff replaces the Figma plan

Supersedes [ADR-0023](0023-designer-returns-figma-and-design-md.md).

## Context and problem statement

ADR-0023 expected the designer to return Figma screens and a DESIGN.md with light and dark tokens. The designer returned a Claude Design canvas export instead, as `SettleIn-handoff.zip`. It holds DECISIONS.md, DESIGN.md, STATES.md, COPY.md, ACCESSIBILITY.md, tokens, assets, wireframes, diagrams, canvas source and about 70 MB of screenshots. Its DECISIONS.md says its 31 decisions win over the brief. The repo needs one source that the ui-builder and coder agents read.

## Considered options

* Commit the handoff without the screenshots to `docs/design/` and leave the screenshots in the owner's Downloads
* Commit the whole handoff, screenshots included
* Ask the designer to redo the handoff in Figma

## Decision outcome

Chosen option: "Commit the handoff without the screenshots", because the owner said "everything except screenshots" (grill 2026-11-25, Q8). DECISIONS.md, as amended by that grill, replaces the spec where they disagree, and the v1.0 spec is updated to match. Agents read the screenshots from `~/Downloads/SettleIn-handoff.zip` by extracting them to their own temporary folder.

### Consequences

* Good, because clones stay small and the text, tokens and assets live next to the code.
* Good, because agents build from written decisions and tokens, not from pixels alone.
* Bad, because the screenshots exist only on the owner's Mac, so a lost Downloads folder loses them.
* Bad, because the canvas is not Figma, so a later Figma file means rebuilding the components there.
