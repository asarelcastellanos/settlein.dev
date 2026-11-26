# Settlein design brief

This brief is for the designer of Settlein. You have not seen the project, and you do not need to ask us anything to start. Everything you need is in this folder.

## What Settlein is

Settlein sets up a new Mac. A person opens settlein.dev, ticks the apps they want and downloads Settlein. The Settlein app shows the list, waits for approval, then downloads, verifies and installs every app. It also removes the apps it installed, with their leftovers.

Settlein is for anyone with a new Mac who does not want to visit a dozen vendor websites. It is free and open source (MIT). It shows no ads and never asks the person to type a Terminal command. The website counts visits with cookieless analytics and sets no cookie. The Mac app sends no data about the person or the Mac to any server. The rules behind these promises are claims [C11](#c11), [C12](#c12), [C13](#c13) and [C27](#c27).

The look is "Quiet and Mac-native". The website is one page with a grid of app icons grouped by category, a sticky bar and light and dark themes. The Mac app should feel like it ships with macOS.

## The flow

1. A person opens settlein.dev and ticks apps. The page address changes to hold the names of the ticked apps ([C7](#c7)). They can bookmark or share that address, and it opens with the same apps ticked ([C8](#c8)).
2. They click the download button in the sticky bar. The browser downloads `Settlein.dmg`. The selection travels in the download link, not in the file name.
3. They open `Settlein.dmg`. macOS mounts the disk image and shows its window. They open Settlein from it. macOS shows its first-open dialog.
4. Settlein opens on the confirmation screen. It lists the ticked apps and waits. Nothing downloads yet ([C18](#c18)).
5. The person approves. Settlein downloads, verifies and installs each app. The progress screen shows the status of every app.
6. A copy app goes straight into the Applications folder. A pkg app is downloaded and verified, then opens in Apple's Installer, where the person clicks through it.
7. The finished screen summarises what was installed, skipped and refused.

On a later visit with Settlein installed, the person ticks apps on the site and clicks the same button. Settlein opens by link and shows the confirmation screen with those apps ([C17](#c17)). The browser asks the person to allow the first open.

When Settlein opens with no selection and has installed nothing, it opens settlein.dev in the default browser. Once it has installed an app, opening it shows the installed list instead ([C16](#c16)).

To uninstall, the person opens the list of apps Settlein installed and uses the control beside an app. Settlein removes the app and its leftovers.

## Screens

Each screen has a grey-box wireframe in [wireframes](wireframes/). The wireframes show content and states. They imply no layout.

The claims are quoted in full under "Spec claims" below. A screen must keep every claim listed for it.

### W1 Catalog, nothing ticked

Wireframe: [web-01-catalog-empty.html](wireframes/web-01-catalog-empty.html)

- Purpose. Let the person find and tick apps.
- Content. All 44 apps in 9 categories, each as an icon and a name. The categories are Browsers, Communication, Developer tools, Media, Creative, Productivity and storage, Games, Security and Utilities. The full list is under "Catalog list" below. The page also needs the Settlein name and a short line saying what it does.
- States. Nothing ticked. An app on hover, on keyboard focus and ticked. The sticky bar when the count is zero.
- Actions. Tick and untick an app. Reach the download button.
- Claims. [C6](#c6) one page, icon and name, grouped by category. [C9](#c9) the sticky bar. [C10](#c10) light and dark. [C11](#c11) no ads. [C12](#c12) no Terminal command. [C13](#c13) no cookie.

### W2 Catalog, apps ticked

Wireframe: [web-02-catalog-selected.html](wireframes/web-02-catalog-selected.html)

- Purpose. Show the selection and offer the download.
- Content. The same grid with ticked apps marked. A bar that stays visible while the page scrolls, with the count of ticked apps and the download button.
- States. One app ticked. Many ticked. A page opened from an address that names apps, with those apps already ticked. An address that names an app the catalog does not hold, which the page ignores without an error.
- Actions. Tick, untick, download.
- Claims. [C7](#c7) the address holds the ticked names. [C8](#c8) an address with names opens with them ticked. [C9](#c9) the bar stays visible and shows the right count and the button. [C10](#c10), [C11](#c11), [C12](#c12).

### W3 After the download click

Wireframe: [web-03-after-download.html](wireframes/web-03-after-download.html)

The spec leaves this screen open. See the open questions. Design what a person needs after the click, and keep the claims. It cannot show a Terminal command ([C12](#c12)). The wireframe holds our starting guess only.

- Purpose. Tell the person what to do next.
- Content. Open to your design, within the claims.
- States. Download started. The person has Settlein installed, so the app opens instead.
- Claims. [C12](#c12), [C15](#c15), [C17](#c17).

### A1 Confirmation

Wireframe: [app-01-confirmation.html](wireframes/app-01-confirmation.html)

- Purpose. Let the person check the list and approve it. This is the guard against a link that names the wrong apps.
- Content. Every selected app with its icon and name. An "already installed" mark on apps that are already on the Mac. A mark on pkg apps that says the app opens in Apple's Installer. An approve button and a cancel button.
- States. A mix of new, already installed and pkg apps. Every app already installed. A long selection that scrolls.
- Actions. Approve. Cancel.
- Claims. [C15](#c15) the screen lists exactly the ticked apps. [C17](#c17) the same on a later visit. [C18](#c18) nothing downloads before approve. [C21](#c21) pkg apps open in Apple's Installer. [C25](#c25) already installed apps are marked and left unchanged. [C27](#c27) no data is sent.

### A2 Installing

Wireframe: [app-02-installing.html](wireframes/app-02-installing.html)

- Purpose. Show progress for every app.
- Content. One row per app with a status. The statuses are waiting, downloading, verifying, installing, done and refused. A refused row names the app and the reason. A pkg app that is open in Apple's Installer shows a "waiting in Apple's Installer" status.
- States. Each status on its own. A run with one refused app while the others continue. A signature refusal and a checksum refusal, which carry different reasons.
- Actions. None are required. You may propose a cancel control, and say what it does.
- Claims. [C19](#c19) every app installs with no vendor site or Terminal. [C20](#c20) no password prompt for copy apps. [C21](#c21) pkg apps. [C22](#c22) a refusal for a missing signature names the app and the reason. [C23](#c23) a refusal for a checksum mismatch names the app and the reason.

### A3 Finished

Wireframe: [app-03-finished.html](wireframes/app-03-finished.html)

- Purpose. Say what happened.
- Content. Counts and lists of installed, skipped (already installed) and refused apps. Each refused app keeps its name and reason. A way to reach the installed list and a way to close Settlein.
- States. All installed. Some skipped. Some refused. Everything refused.
- Actions. Close. Open the installed list.
- Claims. [C19](#c19), [C22](#c22), [C23](#c23), [C25](#c25).

### A4 Installed list

Wireframe: [app-04-installed-list.html](wireframes/app-04-installed-list.html)

- Purpose. Show the apps Settlein installed and let the person remove them. This is the screen a person sees when they open Settlein from Applications after it has installed something ([C16](#c16)).
- Content. A list of apps Settlein installed, each with an uninstall control. It shows no app that the person installed by hand. An "Add apps" button that opens settlein.dev.
- States. Empty list. A list with copy and pkg apps. A pkg app should signal that removal asks for the admin password.
- Actions. Uninstall one app. Add apps.
- Claims. [C16](#c16), [C28](#c28).

### A5 Uninstall

Wireframe: [app-05-uninstall.html](wireframes/app-05-uninstall.html)

- Purpose. Confirm a removal, show progress and show the result.
- Content. A confirmation that names the app and says its leftovers go with it. A progress state. A result that says what was removed, or why a removal failed.
- States. Copy app. Pkg app, where macOS shows one admin password prompt. The person cancels the prompt. A standard user with no admin password cannot remove a pkg app, so the screen needs an explanation for that case.
- Actions. Confirm. Cancel. Close.
- Claims. [C29](#c29) a copy app loses its bundle and leftovers. [C30](#c30) a pkg app asks for the password once. [C31](#c31) only paths the catalog lists are deleted.
- The password prompt is system UI. Do not design it. Design the screen around it.

### A6 Catalog unreachable

Wireframe: [app-06-catalog-unreachable.html](wireframes/app-06-catalog-unreachable.html)

The spec does not cover this state. It is realistic, because the app reads the catalog only from settlein.dev ([C5](#c5)) and the person may be offline.

- Purpose. Tell the person the catalog did not load.
- Content. What failed, in plain words, and what to do next. No Terminal command.
- States. Offline. The site answers with an error.
- Actions. Try again. Close.
- Claims. [C5](#c5), [C12](#c12) applies in spirit to the app too.

### B1 Icon and wordmark

Wireframe: [brand-01-icon-and-wordmark.html](wireframes/brand-01-icon-and-wordmark.html)

- Purpose. Give Settlein an identity.
- Content. The app icon, the wordmark and the website favicon.
- States. Icon at every size macOS needs. Wordmark on light and on dark. Favicon at small sizes.
- Claims. None. The icon must read well beside other Mac app icons in the Dock and in Finder.

### D1 Disk image window

Wireframe: [dmg-01-window.html](wireframes/dmg-01-window.html)

- Purpose. Be the first thing the person sees after opening `Settlein.dmg`.
- Content. The Settlein app icon. A cue that tells the person to open it. Keep the cue free of Terminal commands.
- States. Light and dark macOS appearance, if your background image can adapt.
- Claims. [C12](#c12), [C32](#c32).

## System UI you cannot change

Do not mock these as ours. Show a placeholder frame if a screen needs to depict the moment.

- The Gatekeeper first-open dialog with its Open button ([C32](#c32)). Settlein is signed and notarized, so macOS shows only its standard dialog.
- The browser's prompt to allow opening Settlein from a web link. It appears the first time a person clicks the download button with Settlein installed (assumption S3, checked in the spec work, says Safari and Chrome ask the person to allow the first open).
- The macOS admin password prompt, which appears once when the person removes a pkg app ([C30](#c30)).
- Apple's Installer, which opens for each pkg app ([C21](#c21)).
- The macOS Gatekeeper first-open check for every app Settlein installs, because Settlein keeps the quarantine attribute on each one ([C24](#c24), decision ADR-0011). This is system UI.
- Sparkle's update window, which offers a new version of Settlein ([C33](#c33)).

## Out of your scope

- Do not draw the 44 vendor app icons. The website build sources them.

## What is fixed and what is open

Decision ADR-0023 records this split. The designer returns Figma screens and a `DESIGN.md` file, and layout, type, color and motion stay open.

Fixed.

- Content on every screen above.
- The states listed for each screen.
- Every spec claim listed for each screen.

Open to you.

- Layout.
- Type.
- Color.
- Motion.

Depart from the wireframes when a claim still holds.

Platform constraints.

- The Mac app is SwiftUI on macOS 26 and 27, on Apple silicon ([C26](#c26)). It should look native on both.
- The website follows the system's light or dark appearance ([C10](#c10)). Design both themes. Do not add a theme switch unless you tell us why.
- The website is a static page. It has no ads and sets no cookie.

## What to return

1. Figma screens for every screen and state above, in light and dark.
2. The app icon at the sizes Apple requires for a macOS app icon.
3. The wordmark and the favicon.
4. A `DESIGN.md` file, in the format below.

A coding agent builds the website and the SwiftUI app from `DESIGN.md`. It reads tokens from this one file for both. Write values it can copy without interpretation.

### DESIGN.md format

Use these sections in this order.

1. Color tokens. A table with the columns name, light value, dark value and use. Use hex values. Name each token by role, not by hue.
2. Type scale. A table with name, font family, size, weight, line height and use. Give the website sizes in px and the app sizes in pt. Name a system font as such.
3. Spacing scale. A table with name and value.
4. Radii. A table with name, value and use.
5. Elevation. A table with name, a shadow or blur value for light, a value for dark and use.
6. Motion. A table with name, duration, easing and use. State what happens when the person turns on Reduce Motion.
7. The website's one memorable element. One paragraph that names the single thing a visitor remembers, and where it appears.
8. Per-screen notes. One short subsection for each screen ID (W1 to D1) with anything the Figma file does not show, such as a hover state or a scroll rule.

Example of a color token table with placeholder values.

| Name | Light | Dark | Use |
|---|---|---|---|
| surface | #FFFFFF | #1C1C1E | Page and window background |
| text-primary | #1D1D1F | #F5F5F7 | Body text and app names |
| accent | #0A84FF | #409CFF | Ticked state and the download button |
| danger | #D70015 | #FF453A | Refused status |

## Open questions for the owner

We have not settled questions 2 to 5. Design a sensible answer, and mark it in Figma so we can change it.

1. Settled. Opening Settlein after it has installed an app shows the installed list (A4), with an "Add apps" button that opens settlein.dev (decision ADR-0027, [C16](#c16)).
2. What does W3 show after the download click? The spec says nothing about it.
3. What should the app do while a pkg app waits in Apple's Installer? Settlein cannot tell whether the person finished or cancelled (decision ADR-0005, copy apps are copied and pkg apps open in Apple's Installer), so A2 and A3 may need a state for "check the result".
4. What does a person see when a link names an app the catalog no longer holds (decision ADR-0009, the selection lives in the page address)? W2 ignores it for now.
5. What does a standard user see when they try to remove a pkg app? They have no admin password (decision ADR-0010, removing a pkg app asks for the admin password).

## Spec claims

Each claim is one testable sentence from the spec. A screen must keep every claim listed for it.

### C5

The Settlein app shall read catalog data only from settlein.dev.

### C6

The website shall show every catalog app on one page as an icon with its name, grouped by category.

### C7

When a person ticks or unticks an app, the website shall update the page address to hold the names of the ticked apps.

### C8

When a person opens an address that holds app names, the website shall show those apps ticked.

### C9

The website shall show a bar that stays visible while the page scrolls and holds the count of ticked apps and the download button.

### C10

The website shall follow the system's light or dark appearance.

### C11

The website shall show no ads.

### C12

The website shall never ask the person to run a Terminal command.

### C13

The website shall count visits with cookieless analytics and shall set no cookie.

### C15

When a person with apps ticked clicks the download button on a Mac that has never had Settlein, and opens the downloaded Settlein, the confirmation screen shall list exactly the ticked apps.

### C16

When Settlein opens with no selection and has installed no app, it shall open settlein.dev in the default browser. When it has installed at least one app, it shall show the installed list with a button that opens settlein.dev.

### C17

When Settlein is installed and a person clicks the website's button with apps ticked, Settlein shall open and its confirmation screen shall list exactly the ticked apps.

### C18

Settlein shall download nothing from the selection until the person approves the confirmation screen.

### C19

After the person approves, Settlein shall download and install every app in the selection without the person opening a vendor website or Terminal.

### C20

Settlein shall install a copy app into `/Applications` for an admin user and into `~/Applications` for a standard user.

### C21

For a pkg app, Settlein shall download and verify the installer, then open it in Apple's Installer for the person.

### C22

Settlein shall refuse to install a download that lacks a valid Developer ID signature or Apple notarization, and shall name the app and the reason.

### C23

When a catalog entry has a checksum, Settlein shall refuse to install a download whose SHA-256 differs from it, and shall name the app and the reason.

### C24

Settlein shall keep the quarantine attribute on every app it installs.

### C25

When a selected app is already on the Mac, Settlein shall show it as already installed on the confirmation screen and shall leave it unchanged.

### C26

Settlein shall run on Apple silicon Macs with macOS 27 and macOS 26.

### C27

The Settlein app shall send no data about the person or the Mac to any server.

### C28

Settlein shall show a list of the apps it installed, with an uninstall control for each.

### C29

When the person uninstalls a copy app, Settlein shall remove the app bundle and every leftover path the catalog lists for it.

### C30

When the person uninstalls a pkg app, Settlein shall ask for the admin password once through a macOS prompt and shall then remove the app's system files as well as its bundle and leftovers.

### C31

During an uninstall, Settlein shall delete only paths the catalog lists for that app.

### C32

The Settlein app shall open on a new Mac with no Gatekeeper block, because it is signed with a Developer ID and notarized by Apple.

### C33

The Settlein app shall update itself to a newer released version through Sparkle.

## Catalog list

The catalog holds 44 apps in 9 categories. "pkg" marks an app that opens in Apple's Installer. All other apps are copy apps. The name in backticks is the Homebrew Cask token. "no checksum" marks an app that has no published checksum.

| Category | Apps |
|---|---|
| Browsers | Google Chrome `google-chrome` (no checksum), Firefox `firefox`, Brave `brave-browser` |
| Communication | Zoom `zoom` (pkg), Slack `slack`, Discord `discord`, WhatsApp `whatsapp`, Microsoft Teams `microsoft-teams` (pkg) |
| Developer tools | GitHub Desktop `github`, Visual Studio Code `visual-studio-code`, Cursor `cursor`, Docker Desktop `docker-desktop`, iTerm2 `iterm2`, Sublime Text `sublime-text`, Cyberduck `cyberduck`, Claude `claude`, ChatGPT `chatgpt` |
| Media | Spotify `spotify` (no checksum), VLC `vlc`, Audacity `audacity`, HandBrake `handbrake-app`, OBS `obs`, Plex `plex` |
| Creative | Blender `blender`, GIMP `gimp`, Inkscape `inkscape`, Sketch `sketch` |
| Productivity and storage | LibreOffice `libreoffice`, Dropbox `dropbox`, Google Drive `google-drive` (pkg, no checksum), OneDrive `onedrive` (pkg) |
| Games | Steam `steam`, Epic Games Launcher `epic-games` |
| Security | 1Password `1password`, Bitwarden `bitwarden` |
| Utilities | AppCleaner `appcleaner`, Caffeine `caffeine`, coconutBattery `coconutbattery`, The Unarchiver `the-unarchiver`, Keka `keka`, balenaEtcher `balenaetcher`, AnyDesk `anydesk` (no checksum), Tailscale `tailscale-app` (pkg), TeamViewer `teamviewer` (pkg) |
