# Grill: final design handoff

2026-11-25, version-sized amendment to v1.0, two rounds in the main session with AskUserQuestion.

## Scope

| Question | Answer |
|---|---|
| What is the ask? | "check downloads. we finally got the finalized web and app designs. also we made some changes to the way the app works and website works so make sure to see those. once you are done please go ahead and build out the website to match the dseign and also the mac app please" |
| Source | `~/Downloads/SettleIn-handoff.zip`, 223 files. Its `DECISIONS.md` holds 31 numbered decisions. The handoff says those decisions win over the brief. |
| Decisions taken as given | Every item the handoff marks "Decided" (1 to 14, 16 to 22, 27, 31). The spec changes they cause are listed under "Spec impact" below. |
| Size | Version-sized. The decisions replace C10, C15, C16, C17, C18 and C25, change C29, C30 and C9, and add screens W3, A7, A0, D1 and the footer pages. |

## Round 1

| # | Question | Answer |
|---|---|---|
| Q1 | Proposal 15. What does the website do with a link that names an app the catalog lacks? | Tick the known apps and show a dismissible notice with the count left out. |
| Q2 | Proposal 23. How does the Finished screen show pkg apps? | Their own "Check in Apple's Installer" group. |
| Q3 | Proposal 24. What happens when a standard user tries to remove a pkg app? | SettleIn explains that an administrator must remove it and shows no password prompt. [ADR-0037](../adr/0037-standard-users-cannot-remove-pkg-apps.md) |
| Q4 | Proposal 25. Where do uninstalled files go? | To the Trash. [ADR-0036](../adr/0036-uninstall-moves-files-to-the-trash.md) |
| Q5 | Proposals 26, 28 and 29. Disk image window, menu bar, new states? | Accept all three as drawn. |
| Q6 | Proposal 30. Checkbox border colour? | #7E869E, which passes the 3:1 control contrast rule. |
| Q7 | Do the 4 apps with no published SHA-256 keep signature-only checks? | Yes. C23 stays as written. |

## Round 2

| # | Question | Answer |
|---|---|---|
| Q8 | What goes into `docs/design/`? | "everything except screenshots. just don't bring them over to ther epo leave them where they are please" [ADR-0033](../adr/0033-final-design-handoff-replaces-the-figma-plan.md) |
| Q9 | What happens to feature/website and feature/install? | Review their logic and merge them into release/v1.0, skipping QA on UI claims the redesign replaces. Build the redesign on new feature branches from release. |
| Q10 | Bundle ID after the rename to SettleIn? | `dev.settlein.SettleIn`. [ADR-0038](../adr/0038-rename-the-app-to-settlein-with-a-capital-i.md) |
| Q11 | Address of the Suggest an app form? | The owner will make a Google Form and send the link. It stays a placeholder until then. |

## Round 3

| # | Question | Answer |
|---|---|---|
| Q12 | The W3 error copy names GitHub as the host, but the dmg comes from settlein.dev/dl. What does the error say and offer? | Name settlein.dev, Try again only. The "Get it from GitHub" button is dropped. |
| Q13 | Build the RSS feed the release notes page mentions? | Drop RSS for v1.0. The "Follow changes with RSS" line is removed. |

## ADRs from handoff decisions

| Decision | ADR |
|---|---|
| 17. No confirmation screen | [ADR-0034](../adr/0034-install-starts-without-a-confirmation-screen.md) |
| 19 and 20. Pick apps inside the app, launch logic. Supersedes ADR-0006 and ADR-0027. | [ADR-0035](../adr/0035-pick-apps-inside-the-app.md) |
| Handoff format. Supersedes ADR-0023. | [ADR-0033](../adr/0033-final-design-handoff-replaces-the-figma-plan.md) |
| 4, 16 and 27. Light only | [ADR-0039](../adr/0039-website-and-app-are-light-only.md) |

## Spec impact

| Claim | Change |
|---|---|
| C9 | The bar floats inside the picker and appears after the first tick. On a phone it offers Copy link. |
| C10 | Replaced. The website is light only. |
| C15, C17 | The opened app starts installing the selection. No confirmation screen lists it. |
| C16 | Replaced by the launch logic. With no selection and nothing installed, SettleIn opens Pick apps. |
| C18 | Removed. |
| C19 | Installing starts when SettleIn opens with a selection, and offers Cancel and Change selection. |
| C25 | Already installed apps are skipped and shown as installed in the picker. |
| C29 | The bundle and leftovers move to the Trash. |
| C30 | A standard user gets an explanation instead of the prompt. |
| New | W3 after-download page, release notes timeline, footer pages, unknown-app notice, A7 in-app picker, Finished screen with the Installer group, menu bar, disk image window, name SettleIn. |
