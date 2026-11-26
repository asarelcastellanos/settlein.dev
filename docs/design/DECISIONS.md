# SettleIn: owner decisions for implementation

Read this before the design brief (README.md) and the canvas. Where this file and the brief disagree, this file wins. Each decision says what it replaces so the spec can be updated.

Status key: **Decided** means the owner chose it. **Proposal** means the designer suggested it and the owner has not overruled it; build it, but keep it easy to change.

## Product

1. **Decided. The name is SettleIn** (capital I), everywhere: UI, wordmark, file name `SettleIn.dmg`. Domain stays `settlein.dev`.
2. **Decided. App icon: concept A, "Unpacked".** Three white tiles thrown out of an open white box, on the blue-violet gradient (#5B7BFF to #8A5CF0). Final artwork: canvas page Brand, board B1. No checkmarks on the tiles.
3. **Decided. Animated icon** (tiles pop out of the box, 0.12 s apart) plays once in these places only: website header on page load, disk image window, first launch, Finished screen. Everywhere else the icon is still. Reduce Motion shows the still icon.

## Website (settlein.dev)

4. **Decided. Light only. No dark mode.** Replaces C10 (follow the system appearance). No theme switch.
5. **Decided. Background:** pale blue-lavender base (#EEF1F8) with soft blue, violet and cyan glows ("aurora"). Not plain white.
6. **Decided. Home page is a scroll story.**
   - The hero has the headline on two lines ("Your new Mac," / "Settled In."), one subhead ("SettleIn installs every app, all in one go."), and three lines that highlight in step with a looping demo window: "Select from a curated set." / "We verify the signature." / "Uninstall whenever you want."
   - Scrolling zooms the demo window into a full-screen app picker (20 px inset, rounded) titled "Pick the apps for your Mac."
7. **Decided. The picker:**
   - All 44 apps in four columns grouped by category, with square checkboxes.
   - No category sidebar. Each category has a checkbox that is ticked only when the whole category is ticked, plus a "Select all" / "Deselect all" label. The page also has Select all and Deselect all buttons.
8. **Decided. Floating glossy bar** inside the picker: the ticked apps' icons, the count, and "Download SettleIn", which appears only after the first tick.
9. **Decided. No pills** anywhere. Nav links are plain text with an underline on hover. The GitHub link uses GitHub's official mark (from Primer Octicons, MIT licensed).
10. **Decided. Mobile:** you can't download a Mac app on a phone, so the bar offers "Copy link" instead of Download. The demo window is replaced by the animated icon, and the picker becomes one column.
11. **Decided. After the download click (W3):** a simple page with "Your download has started.", the list of apps in the download, "Change selection" and "Download again", and one line for people who already have SettleIn. Answers open question 2.
12. **Decided. Footer:**
   - Release notes; Source code, Report a problem, Suggest an app (an outside form, Google Forms or similar); How apps are verified; What SettleIn sends.
   - No MIT license page or link, and no Suggest an app page.
   - Bottom line: "© 2026 SettleIn contributors" and "Not affiliated with Apple. App names and icons belong to their owners."
13. **Decided. Footer pages** are open sections on the background (icon, heading, short stacked sentences). No white panels.
14. **Decided. Release notes are one timeline** with three entry types, filterable: App update (versioned, ships through Sparkle), Catalog change (apps added, removed or changed on settlein.dev; no app update needed), and Notice (for example an app paused after failing a check).
15. **Proposal. Unknown app in a link:** known apps are ticked, and a one-line dismissible notice says how many were left out. Open question 4.

## Mac app

16. **Decided. Light only.** Force it with `.preferredColorScheme(.light)` on the root view.
17. **Decided. No confirmation screen.** Whenever SettleIn opens with a selection, it starts downloading and installing straight away. The selection can come from the downloaded disk image or from a settlein.dev link. Replaces C18 (download nothing until the person approves) and removes screen A1.
18. **Decided. The Installing screen always offers Cancel and Change selection.**
   - Cancel: the app in progress finishes, waiting apps are skipped, installed apps stay.
   - Change selection: the app in progress finishes, then Pick apps opens with the same list ticked.
19. **Decided. Picking happens inside the app (screen A7, Pick apps).** It's the same layout as the website picker. Installed apps are marked and can't be ticked, and the bar says "Install N apps". It opens from Add apps on the installed list, from Change selection, and when SettleIn opens with nothing installed and no selection. Replaces C16's "open settlein.dev in the browser" and A4's Add apps link.
20. **Decided. Launch logic:**
   - opened with a selection → Installing
   - no selection and nothing installed → Pick apps
   - otherwise → Installed list (A4)
21. **Decided. Pop-ups are centred panels over a dimmed window,** not `.sheet` (macOS sheets drop from the title bar). One reusable overlay is used for Uninstall, Cancel and Change selection. Esc cancels.
22. **Decided. Look:** the same style as the website's full-screen picker. Translucent window, traffic lights, rows of 52 pt, icons of 34 pt, accent #3A5BEF, and the glossy bottom bar via `.glassEffect` on macOS 26 and 27.
23. **Proposal. Installer-package apps** (Zoom, Microsoft Teams, Google Drive, OneDrive, Tailscale, TeamViewer) get their own "Check in Apple's Installer" group on the Finished screen, because SettleIn can't see whether the person finished. Open question 3.
24. **Proposal. Standard user removing an installer-package app** sees an explanation (needs an administrator) instead of a password prompt they can't complete. Open question 5.
25. **Proposal. Uninstall moves files to the Trash**, so mistakes are recoverable. It still deletes only paths the catalog lists (C31).
26. **Proposal. Disk image window:** the SettleIn icon, an Applications shortcut, and the cue "Drag SettleIn to Applications, then open it." No Terminal command.

## Added in the hand-off (25 November 2026)

27. **Decided. Dark tokens are reserved, not shipped.** DESIGN.md and the framework board list a dark value for every colour, so dark mode can be added later. Decisions 4 and 16 still stand: light only.
28. **Proposal. Menu bar** (board A0):
    - **SettleIn menu:** About SettleIn, Check for Updates…, Hide, Hide Others, Quit.
    - **Apps menu:** Pick Apps… ⌘N, Installed Apps ⌘1, Change Selection… ⌘E, Cancel the Rest… ⌘.
    - **Help menu:** How SettleIn Checks Apps, What SettleIn Sends, Report a Problem…, settlein.dev.
29. **Proposal. New states** (STATES.md):
    - A4 loading and record unreadable.
    - W3 download didn't start.
    - Phone link copied and couldn't copy.
    - JavaScript turned off.
    - A7 loading is decided as drawn, because it follows the A6 pattern.
30. **Proposal. Checkbox border #7E869E** instead of #A9B0C6, to meet the 3:1 contrast rule for controls (ACCESSIBILITY.md, A-1). The boards still show the old value.
31. **Fixed in copy.** Release notes no longer say "Review the list in SettleIn, then approve", and What SettleIn sends says "the apps you pick", not "the apps you approve". Both followed decision 17.

## Rules that still hold from the brief

- The catalog comes only from settlein.dev (C5).
- Refuse downloads without a valid Developer ID signature or Apple notarization, or with a SHA-256 mismatch, and name the app and the reason (C22, C23).
- Keep the quarantine attribute on every installed app (C24).
- Copy apps install with no password prompt, into `/Applications` for admins and `~/Applications` for standard users (C20).
- Send no data about the person or the Mac (C27).
- During uninstall, touch only catalog-listed paths (C31).
- The website shows no ads and sets no cookies (C11, C13).

## Placeholders still to fill

- Release notes: [VERSION] and [RELEASE DATE].
- Every GitHub link, and the address of the Suggest an app form.
- Favicon: done. See `assets/web/` (favicon.svg, favicon.ico, 16/32/48/192/512 px PNGs, apple-touch-icon).
- The analytics vendor named on What SettleIn sends (cookieless, not yet chosen).
