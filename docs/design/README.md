The screenshots stay in the owner's copy of SettleIn-handoff.zip and are not in this repository ([ADR-0033](../adr/0033-final-design-handoff-replaces-the-figma-plan.md)).

# SettleIn design hand-off

SettleIn (settlein.dev) is a Mac app plus a website for setting up a new Mac. You pick apps from a curated catalog. SettleIn downloads them, checks each one's signature, notarization and checksum, installs them all in one go, and can uninstall them later.

This folder holds everything needed to build the website and the Mac app (SwiftUI, macOS 26/27). It's written for a developer or a coding agent.

## Start here, in this order

1. **DECISIONS.md.** The owner's decisions (31 of them). Where they disagree with the original brief, they win. Items marked Proposal are the designer's calls; build them, but keep them easy to change.
2. **DESIGN.md.** Tokens (colour, type, spacing, radii, elevation, motion), components, and notes for every screen.
3. **STATES.md.** Every screen against empty, loading, error and success, with the board and screenshot for each.
4. **diagrams/.** How the pieces connect: site flow, app launch logic, install pipeline, uninstall, scroll timeline, icon animation.
5. **screenshots/.** What it looks like. Then **wireframes/** for structure, **COPY.md** for every string, and **ACCESSIBILITY.md** before you ship.

## What's in the folder

| Folder / file | What it holds |
|---|---|
| `DECISIONS.md` | Owner decisions, rules still holding from the brief, placeholders to fill |
| `DESIGN.md` | Design system, light only (dark values reserved) |
| `STATES.md` | State matrix for every screen |
| `COPY.md` | Copy deck: every string, by screen, plus voice rules |
| `ACCESSIBILITY.md` | WCAG 2.2 AA / macOS checklist, contrast table, two fixes to make |
| `tokens/` | `tokens.json`, `tokens.css` (custom properties) and `Tokens.swift` (Color and spacing constants) |
| `assets/icon/` | App icon: 1024 PNG, still and animated SVG, `SettleIn.icns` |
| `assets/AppIcon.appiconset/` | Drop-in Xcode icon set with Contents.json (16–512 px at @1x and @2x) |
| `assets/AppIcon.iconset/` | The same sizes in iconutil format |
| `assets/web/` | favicon.svg and .ico, 16/32/48/192/512 px PNGs, apple-touch-icon, Open Graph image (1200 × 630) |
| `assets/dmg/` | Disk image background, 660 × 420 at @1x and @2x |
| `assets/wordmark/` | Icon + "SettleIn" lockup (SVG, PNG) and a text-only SVG |
| `screenshots/website-1440/` | Every website page at desktop width (1440 px), full length |
| `screenshots/website-375/` | Every website page at 375 px (iPhone), full length |
| `screenshots/scroll-story/` | Six frames of the home page scroll at 1440 × 900 |
| `screenshots/hero-demo/` | Five frames of the hero demo loop |
| `screenshots/mac/` | All 28 Mac app boards, plus the flow map. `00-mac-app-overview.png` shows them all at once |
| `screenshots/website/`, `mobile/`, `brand/`, `framework/`, `handoff/` | Every other canvas board as rendered |
| `wireframes/` | Seven grey-box wireframes with numbered notes (SVG and PNG) |
| `diagrams/` | Six flow and timing diagrams (SVG and PNG) |
| `canvas-source/` | Board source files and a preview runtime (see its README) |

## Screen index

**Website**
- **W1 Home:** hero with a looping demo; scrolling zooms it into a full-screen app picker.
- **W2 Home from a link:** some apps in the link aren't offered.
- **W3 After the download click.**
- **Footer pages:** Release notes, How apps are verified, What SettleIn sends.
- **Phone views** at 375 px.

**Mac app**
- **A0** Menu bar
- **D1** Disk image window
- **A7** Pick apps
- **A2** Installing
- **A3** Finished
- **A4** Installed list
- **A5** Uninstall
- **A6** Catalog unreachable

There is no A1: the old approval screen was removed by decision 17.

**Brand**
- **B1** App icon, final
- **B2** Icon explorations, kept for the record

## About "Figma screens"

The brief asked for Figma. This hand-off uses a Claude Design canvas instead, plus the exported screenshots, SVG wireframes and diagrams here. Every board is also a PNG in `screenshots/`. Every icon and graphic is an SVG you can import into Figma (File › Import) if a Figma file is needed later. The canvas boards aren't Figma frames, so Auto Layout and components would have to be rebuilt there.

## Open items for the owner

- **Placeholders:**
  - [VERSION] and [RELEASE DATE] in the release notes.
  - Every GitHub URL.
  - The Suggest an app form URL.
  - The cookieless analytics vendor named on What SettleIn sends.
  - [DATE] on the installed list.
- **Proposals to confirm or overrule:**
  - 15: unknown apps in a link.
  - 23: Check in Apple's Installer group.
  - 24: standard user removing an installer-package app.
  - 25: uninstall to the Trash.
  - 26: disk image layout.
  - 28: menu bar.
  - 29: new error and empty states.
  - 30: darker checkbox border for contrast.
- **Checksums:** the release notes say 4 apps rely on signature and notarization because their developers publish no checksum. The verification flow treats a SHA-256 mismatch as a refusal. Confirm how those 4 apps are handled (no hash check, or a hash the catalog computes itself).
- **Dark mode:** values exist (DESIGN.md), but light-only stands until the owner says otherwise.
- **Trademark:** concept C (an open box) resembled Apple's installer-package icon and was set aside. The final icon is concept A, with a flapless white box. A quick trademark search before launch is still worth doing.
