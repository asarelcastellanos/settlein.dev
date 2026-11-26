# SettleIn design system (DESIGN.md)

Version 1.0 · 25 November 2026 · for the website (settlein.dev) and the Mac app.

**Light ships, dark is reserved.** Neither the site nor the app has a dark mode (DECISIONS.md #4, #16). The dark column below exists so a dark mode can be added later without new design work. Don't wire it up now.

Same values as the canvas board "Design framework v1.0". Where this file and a board disagree, this file wins.

## 1. Color

Hex values, sRGB. "at N%" means that colour at N% opacity. An 8-digit hex ends in its alpha.

| Token | Light (ships) | Dark (reserved) | Use |
|---|---|---|---|
| `ground-base` | `#EEF1F8` | `#0E1120` | Page base under the glows (website); app window wallpaper in mock-ups |
| `ground-glow-blue` | `#6E8CFF at 38%` | `#6E8CFF at 26%` | Radial glow, top left, 900 × 600 px |
| `ground-glow-violet` | `#B982FF at 30%` | `#B982FF at 20%` | Radial glow, top right, 800 × 600 px |
| `ground-glow-cyan` | `#50C8E6 at 22%` | `#50C8E6 at 12%` | Radial glow, bottom, 1000 × 700 px |
| `surface-panel` | `#FFFFFFB8` | `#1A1E30B8` | Frosted panels and the address strip (blur 24 px) |
| `surface-window` | `#FFFFFFD9` | `#171A2AE6` | Website app window and the Mac app window (blur 30–40 px) |
| `surface-side` | `#F1F3FA` | `#20243A` | Side areas, path lists, notes inside panels |
| `row-hover` | `#E6EAF5` | `#262B44` | Row and button hover, progress track |
| `separator` | `#DCE1EE` | `#2E3450` | Hairlines between rows and sections |
| `text-primary` | `#1A1D2B` | `#EEF0F8` | Headings, app names, body |
| `text-secondary` | `#545A6E` | `#A3A9BE` | Supporting text, counts, captions (6:1 on base) |
| `accent` | `#3A5BEF` | `#3A5BEF` | Primary button fill (with accent-hi gradient), ticked checkbox |
| `accent-hi` | `#5F7DFF` | `#5F7DFF` | Top of the primary button gradient |
| `accent-text` | `#3048D6` | `#93A6FF` | Links, Select all, eyebrow labels |
| `accent-tint` | `#E3E8FF` | `#252E5E` | Ticked row, verifying row, banners |
| `focus-ring` | `#3A5BEF` | `#93A6FF` | 3 px keyboard focus outline, 2 px offset |
| `checkbox-edge` | `#A9B0C6` | `#5D6480` | Square checkbox border at rest. 2.2:1 on white: see ACCESSIBILITY.md, fix A-1 |
| `icon-placeholder` | `#E1E5F1` | `#2A2F48` | App icon slot before the real icon loads |
| `success` | `#1A7F37` | `#3FB950` | Done, Installed. Use on window surfaces (5:1 on white), not on the ground (4.49:1) |
| `warning` | `#8A5A00` | `#E3B341` | Waiting in Apple’s Installer, notices |
| `warning-tint` | `#FFF4DC` | `#3A2F12` | Installer row background |
| `danger` | `#C4161C` | `#FF6B6B` | Refused and its reason |
| `danger-tint` | `#FDE8E8` | `#3D1A1E` | Refused row background |
| `destructive` | `#D92D2D` | `#D92D2D` | Uninstall button fill |
| `disabled` | `#DCE1EE / #7E8499` | `#2E3450 / #6E748C` | Disabled button fill / label |

**Ground.** `ground-base` with three radial glows:
- blue: 900 × 600 px at 8% / -2%
- violet: 800 × 600 px at 95% / 4%
- cyan: 1000 × 700 px at 50% / 105%

Each glow fades to transparent at 70%. The ground is fixed to the page, not the viewport.

**One accent.** Indigo `accent` is the only brand colour in the UI. Status colours (success, warning, danger) appear only on status words, icons and their tinted rows.

**SwiftUI.**
- Define each token once in an asset catalog with the Light value only (Appearances: None), because the app forces `.preferredColorScheme(.light)`.
- Use system materials for glass (`.glassEffect()`, `.ultraThinMaterial`) rather than re-creating the blur.

**CSS.** Expose them as custom properties on `:root`, for example `--accent: #3A5BEF`. To add dark mode later, put the dark column under `@media (prefers-color-scheme: dark)`.

## 2. Type

The system font everywhere: SF Pro on Apple devices, with Inter as the web fallback. No web font is loaded for Apple visitors.

### 2a. Website (px)
| Name | Family | Size | Weight | Line height | Use |
|---|---|---|---|---|---|
| display | System font (SF Pro) | clamp(38–62 px) | 800 | 1.04 | Home headline, two lines |
| page-title | System font | 56 px | 800 | 60 px | Footer page titles |
| app-title | System font | 36 px | 800 | 42 px | "Pick the apps for your Mac." |
| section | System font | 24 px | 700 | 30 px | Footer page section headings |
| lede | System font | 20 px | 400 | 30 px | Hero subhead, page intros |
| body | System font | 17 px | 400 | 27 px | Section text |
| row | System font | 15 px | 500 | 20 px | App names in the picker |
| label | System font | 13 px | 700 | 20 px | Category headings, eyebrows (uppercase .06em) |
| caption | System font | 12–13 px | 400–600 | 18 px | Footer, counts |
| mono | ui-monospace (SF Mono) | 13 px | 400 | 18 px | Addresses, paths |

### 2b. Mac app (pt)
| Name | Family | Size | Weight | Line height | Use |
|---|---|---|---|---|---|
| window-title | System font | 26 pt | Bold | 32 pt | Screen headings ("Installing 7 apps") |
| row-name | System font | 15 pt | Semibold | 20 pt | App names |
| row-detail | System font | 13 pt | Regular | 18 pt | Status details, reasons |
| status | System font | 13 pt | Semibold | 18 pt | Done, Refused, Waiting… |
| section | System font | 12 pt | Bold, uppercase | 16 pt | Finished screen groups |
| button | System font | 14 pt | Semibold | 18 pt | Buttons |
| panel-title | System font | 18 pt | Bold | 24 pt | Centred panel titles |
| path | SF Mono | 11.5 pt | Regular | 17 pt | Leftover paths in Uninstall |

Display text uses letter-spacing of -0.03 em; headings use -0.02 em; body uses 0. Mac app text follows Dynamic Type sizes where SwiftUI provides them (`.title`, `.body`, `.callout`); the pt values above are the defaults at the standard size.

## 3. Spacing

A 4-based scale. Use these values only.

| Token | Value |
|---|---|
| `space-1` | 4 px / pt |
| `space-2` | 8 px / pt |
| `space-3` | 12 px / pt |
| `space-4` | 16 px / pt |
| `space-5` | 24 px / pt |
| `space-6` | 32 px / pt |
| `space-7` | 48 px / pt |
| `space-8` | 64 px / pt |
| `space-9` | 96 px / pt |

Common uses:
- Page side padding is 80 px on desktop and 16–20 px on a phone.
- Section gap is 48–64 px. Row padding is 4 × 10 px. Gaps inside the glass bar are 14 px.
- The Mac window content inset is 24–32 pt.

## 4. Radii
| Token | Value | Use |
|---|---|---|
| r-checkbox | 4–5 px | Square checkboxes |
| r-row | 7–9 px | Rows, sidebar items |
| r-button | 10–12 px | Buttons |
| r-panel | 16–20 px | Centred panels, glass bars, frosted panels |
| r-window | 14 px (app mock) / 18 px (site full screen) | Windows |
| r-icon | 22.37% | App icon squircle and placeholders |

## 5. Elevation
| Token | Value | Use |
|---|---|---|
| e-window | `0 0 0 1px #DCE1EE, 0 30px 80px rgba(20,30,80,.22)` | App windows (site and Mac) |
| e-glass | `inset 0 1px 0 rgba(255,255,255,.95), 0 0 0 .5px rgba(20,30,80,.14), 0 2px 6px rgba(20,30,80,.08), 0 20px 50px rgba(20,30,80,.22); fill linear-gradient(180deg, rgba(255,255,255,.78), rgba(244,246,255,.55)); blur 30 px, saturate 200%` | Floating selection bar, app bottom bars |
| e-panel | `0 0 0 1px #DCE1EE, 0 24px 60px rgba(10,15,40,.30)` | Centred panels |
| e-button | `inset 0 1px 0 rgba(255,255,255,.38), inset 0 -1px 0 rgba(0,0,0,.12), 0 6px 18px rgba(58,91,239,.32)` | Primary button |
| e-dim | `rgba(10,15,40,.22)` | Window dim behind a centred panel |

Only four levels: window, glass bar, panel, button. Nothing else casts a shadow. Rows, sections and footer pages sit flat on the ground (no white cards; DECISIONS.md #13).

## 6. Motion
| Token | Duration | Easing | Use |
|---|---|---|---|
| m-hover | 120 ms | ease-out | Row, link and button hover |
| m-tick | 160 ms | cubic-bezier(.2,.8,.2,1) | Checkbox fill and row tint |
| m-press | 220 ms | cubic-bezier(.22,1,.36,1) | Button press: scale .94 |
| m-pane | 450 ms opacity / 650 ms move | ease / cubic-bezier(.22,1,.36,1) | Demo screens crossfade and rise 16 px |
| m-step | 600 ms | cubic-bezier(.22,1,.36,1) | Hero step highlight slides |
| m-pop | 320 ms | cubic-bezier(.34,1.4,.64,1) | Icons dropping into the bar |
| m-bar | 850–900 ms | cubic-bezier(.4,0,.2,1) | Download progress fill |
| m-icon-once | 900 ms per tile, 0 / 120 / 240 ms delays | cubic-bezier(.34,1.45,.64,1) | App icon plays once: tiles from scale .25 in the box opening to place |
| m-icon-loop | 3.2 s loop | cubic-bezier(.34,1.45,.64,1) | Icon loop (brand board only): out by 34%, hold to 82%, back in by 96% |
| m-demo | 450 ms per frame, 33 frames | steps | Hero demo: 0–8 choose, 9–24 verify, 25–32 uninstall |
| m-scroll | follows scroll, eased 0.2 per frame | easeInOutCubic over 60% of the scroll | Hero window zooms to full screen; picker fades in over the first 12% |

**Reduce Motion** (`prefers-reduced-motion: reduce` on the web; `accessibilityReduceMotion` in SwiftUI):
- No zoom, slide or spring.
- The hero demo starts paused, and the scroll zoom is replaced by the stacked layout.
- The icon is still.
- Panels fade in over 120 ms.

### 6a. Icon animation, in numbers
- Three tiles, delays 0 / 120 / 240 ms, each 900 ms: 1140 ms in total.
- **Start:** each tile is at scale 0.25, centred in the box opening (512, 604 in the 1024 grid), with rotation undone (−28°, 0°, +28°) and opacity 0.
- **Movement:** opacity reaches 1 at 15% of the tile's time. Position, rotation and scale ease with `cubic-bezier(.34, 1.45, .64, 1)`, which overshoots about 6% before settling.
- **SwiftUI:** `keyframeAnimator` per tile, or `.spring(response: 0.55, dampingFraction: 0.62)` with `.delay(0.12 × index)`.
- **Where it plays once:** the website header on page load, the disk image window, the app's first launch, and the Finished screen (A3). Everywhere else it is still.
- **Loop version** (brand board only): 3.2 s. Tiles go out by 34%, hold until 82%, and are back in by 96%.

## 7. The memorable element

**The demo window that becomes the app.**
- On the home page, the small SettleIn window plays the whole product in the hero: choose, verify, uninstall.
- As you scroll, it zooms up and becomes the real, full-screen picker.
- The picker's floating glass bar collects the icons of the apps you tick, like a Dock. "Download SettleIn" appears after the first tick.
- The Mac app opens into the same picker and the same bar. The website and the app look like one product.

Protect it:
- Nothing else on the page animates while the demo plays.
- The bar is always full width inside its window.
- Nothing else uses glass.

## 8. Components

- **Square checkbox.**
  - 18 px, radius 5. The accent fill appears on tick.
  - A category checkbox is ticked only when every app in it is ticked. There is no mixed (dash) state.
- **Picker row.**
  - 40 px tall on the web (44 px on a phone, 52 pt in the app). Holds the checkbox, a 28 px icon and the name.
  - Hover is `row-hover`. Ticked is `accent-tint`. The whole row toggles.
- **Glass bar.** Icons of the ticked apps (empty dashed slots when none), the count, and one primary action. It floats 12–16 px from the window's bottom edge.
- **Buttons.**
  - Primary: gradient indigo. Secondary: white with a hairline. Destructive: red.
  - Text links are underlined and never shaped like pills (DECISIONS.md #9).
- **Centred panel.**
  - 340–420 pt wide, over the dimmed window. Cancel sits on the left and the action on the right.
  - Esc cancels. Return triggers Cancel when the action is destructive.
- **Status row (app).**
  - Each status has one word on the right: Waiting, Downloading, Verifying, Done, Refused, Skipped, or Show Installer.
  - A plain-language line under the name says what happened.

## 9. Screen notes

### Website
- **W1 Home:**
  - The headline is two lines. "Your new Mac," never wraps.
  - Choose your apps scrolls to the picker; Play demo / Pause controls the loop.
  - The scroll zoom needs a window of at least 900 × 640. Smaller windows, phones and Reduce Motion get the stacked layout.
- **W1 picker:**
  - Four columns at 1440, three at 1100, two at 760, and one on a phone.
  - Select all / Deselect all sit top right.
  - The address updates to `?apps=` as people tick, so a selection can be shared or reloaded.
- **W2 from a link:** known apps are ticked. A one-line dismissible notice counts the apps that were left out and never names them.
- **W3 After the download click:** a confirmation and the app list, with Change selection and Download again. No instructions about opening the disk image.
- **Footer pages** (How apps are verified, What SettleIn sends, Release notes):
  - Eyebrow, title and intro, then sections with the heading on the left and stacked sentences on the right.
  - On a phone, each heading stacks above its text.
- **Release notes:** one timeline with All / App updates / Catalog / Notices tabs. Each entry type has its own small label colour and a version or date column.
- **Phone (375 px):**
  - The animated icon replaces the demo, and the picker is one column.
  - The sticky bar shows Copy link, which turns into "Link copied" with a tick for 2 s.
  - No horizontal scrolling at 375 px. This is checked in `screenshots/website-375`.

### Mac app (macOS 26/27, SwiftUI, light only)
- **A0 Menu bar:** the SettleIn, Apps and Help menus with shortcuts (proposal).
- **D1 Disk image:** a 660 × 420 window, background `assets/dmg/dmg-background@2x.png`. The app icon sits at (165, 200) and the Applications link at (495, 200).
- **A7 Pick apps:**
  - The same picker as the website. Installed apps show a green check and can't be ticked.
  - The bar shows Install N apps.
  - States: loading (placeholder rows), empty, ticked, and catalog unreachable (A6).
- **A2 Installing:**
  - Opens straight into downloading. Each row shows its own status.
  - The bar has Change selection and Cancel.
  - Refusals name the reason. Nothing to install has its own screen.
- **A3 Finished:** groups for Installed, Check in Apple's Installer, Already on this Mac, and Refused. Show installed apps and Done. The icon plays once.
- **A4 Installed list:** only apps SettleIn installed. Installer-package apps show a lock. States: loading, empty, and record unreadable.
- **A5 Uninstall:** a centred panel lists the leftover paths, which move to the Trash. It covers the macOS password prompt, the prompt being cancelled, a failed removal, and a standard user.
- **A6 Catalog unreachable:** offline, site error, or retrying. Close and Try again.
- **B1 Icon:** see `assets/` and board B1. Never put the animated icon in the Dock.
