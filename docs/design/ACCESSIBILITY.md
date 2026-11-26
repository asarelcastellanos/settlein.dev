# Accessibility checklist

Target: WCAG 2.2 AA on settlein.dev, and the macOS Accessibility guidelines in the app. Contrast figures below are measured against the tokens in DESIGN.md.

## Fixes to make before build

- **A-1. Checkbox border contrast.**
  - The light `checkbox-edge` #A9B0C6 is 2.2:1 on white, and WCAG 1.4.11 asks 3:1 for controls.
  - Use **#7E869E** (3.6:1 on white, 3.0:1 on the ticked-row tint) for the unticked border.
  - The look barely changes. I haven't restyled the boards: owner decides.
- **A-2. Success text on the ground.**
  - #1A7F37 is 5.1:1 on white but 4.49:1 on `ground-base`.
  - Keep success text on window and panel surfaces only, which is where it is today.

## Contrast (light, which ships)

| Pair | Ratio | Passes |
|---|---|---|
| text-primary on ground | 14.8:1 | AA, AAA |
| text-secondary on ground | 6.1:1 | AA |
| accent-text (links) on ground | 6.1:1 | AA |
| white on accent (primary button) | 5.4:1 | AA |
| white on destructive (Uninstall) | 4.8:1 | AA |
| warning text on ground | 5.2:1 | AA |
| danger text on ground | 5.3:1 | AA |

The reserved dark values pass the same checks. Buttons keep the light accent fill (#3A5BEF) in dark mode, because the brighter indigo was only 3.7:1 with white text.

## Website

- [ ] One `h1` per page. The headline is "Your new Mac, Settled In." as one heading with a line break; screen readers hear one sentence.
- [ ] The picker is a `fieldset` per category, with a `legend` that includes the category name. Each app is a real `<input type="checkbox">` with its label wrapping the row, so the whole row is a 40 px (phone 44 px) target.
- [ ] A category checkbox's accessible name is "Select all in Media" or "Deselect all in Media". It is ticked only when all apps are ticked, with no `aria-checked="mixed"`, matching the design.
- [ ] The glass bar count is in an `aria-live="polite"` region: "3 apps selected". "Link copied" and "Couldn't copy" are announced the same way.
- [ ] The scroll zoom is decoration: the picker is in the DOM order right after the hero, so keyboard and screen reader users reach it without scrolling tricks. `Choose your apps` is a skip link to it.
- [ ] Demo window: `aria-hidden="true"` with a visible Play demo / Pause button (WCAG 2.2.2). The demo starts paused under `prefers-reduced-motion`.
- [ ] Focus: a 3 px `focus-ring` outline with a 2 px offset on every interactive element, never removed. The sticky bar never covers the focused row (`scroll-padding-bottom: 96px`).
- [ ] Zoom to 200% and a 320 px width: no horizontal scrolling. 375 px is checked in `screenshots/website-375`.
- [ ] App icons in the picker are decorative (`alt=""`); the name is the label.
- [ ] External links (↗) carry "(opens GitHub)" or similar in their accessible name.
- [ ] Language is `lang="en"`. Release-note dates use `<time datetime>`.

## Mac app

- [ ] Every row is one accessibility element: "Slack, Done", "Brave, Refused, the download isn't signed with a valid Developer ID". Use `.accessibilityElement(children: .combine)` and give status words `.accessibilityValue`.
- [ ] Progress: `ProgressView(value:)` per row, which VoiceOver reads as "Downloading, 64 percent". Announce each finished app with `AccessibilityNotification.Announcement` at low priority, and the screen title change at the end.
- [ ] Full keyboard access: Tab moves through rows and buttons, Space ticks, Return is the bar's primary action, Esc closes panels. Shortcuts are listed on the menu bar board (A0).
- [ ] Centred panels: focus moves into the panel, is trapped there, and returns to the row that opened it. Use `.accessibilityAddTraits(.isModal)` on the panel.
- [ ] Destructive panels default to Cancel (Return = Cancel).
- [ ] Reduce Motion: no spring, zoom or icon animation; panels fade over 120 ms. Reduce Transparency: glass and window translucency become solid `surface-window`. Increase Contrast: separators move to `text-secondary` and checkbox borders to `text-primary`.
- [ ] Dynamic Type isn't available on macOS, but the layout holds at the larger system text size (System Settings › Accessibility › Display › Text size).
- [ ] Colour is never the only signal: each status has a word and an SF Symbol (checkmark.circle, xmark.octagon, clock, lock) as well as its colour.
- [ ] VoiceOver labels for icon-only controls: the lock on installer-package apps reads "Removing asks for your admin password".
