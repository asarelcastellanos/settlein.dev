# Settlein design brief

This brief is for the designer of Settlein. You have not seen the project, and you do not need to ask us anything to start. Everything you need is here or in a file this brief links.

## What Settlein is

Settlein sets up a new Mac. A person opens settlein.dev, ticks the apps they want and downloads Settlein. The Settlein app shows the list, waits for approval, then downloads, verifies and installs every app. It also removes the apps it installed, with their leftovers.

Settlein is for anyone with a new Mac who does not want to visit a dozen vendor websites. It is free and open source (MIT). It shows no ads and never asks the person to type a Terminal command. The website counts visits with cookieless analytics and sets no cookie. The Mac app sends no data about the person or the Mac to any server. The rules behind these promises are claims [C11, C12, C13 and C27](../spec/v1.0.md).

The look is "Quiet and Mac-native". The website is one page with a grid of app icons grouped by category, a sticky bar and light and dark themes. The Mac app should feel like it ships with macOS.

## The flow

1. A person opens settlein.dev and ticks apps. The page address changes to hold the names of the ticked apps ([C7](../spec/v1.0.md)). They can bookmark or share that address, and it opens with the same apps ticked ([C8](../spec/v1.0.md)).
2. They click the download button in the sticky bar. The browser downloads `Settlein.dmg`. The selection travels in the download link, not in the file name.
3. They open `Settlein.dmg`. macOS mounts the disk image and shows its window. They open Settlein from it. macOS shows its first-open dialog.
4. Settlein opens on the confirmation screen. It lists the ticked apps and waits. Nothing downloads yet ([C18](../spec/v1.0.md)).
5. The person approves. Settlein downloads, verifies and installs each app. The progress screen shows the status of every app.
6. A copy app goes straight into the Applications folder. A pkg app is downloaded and verified, then opens in Apple's Installer, where the person clicks through it.
7. The finished screen summarises what was installed, skipped and refused.

On a later visit with Settlein installed, the person ticks apps on the site and clicks the same button. Settlein opens by link and shows the confirmation screen with those apps ([C17](../spec/v1.0.md)). The browser asks the person to allow the first open.

When Settlein opens with no selection, it opens settlein.dev in the default browser ([C16](../spec/v1.0.md)).

To uninstall, the person opens the list of apps Settlein installed and uses the control beside an app. Settlein removes the app and its leftovers.

## Screens

Each screen has a grey-box wireframe in [wireframes](wireframes/). The wireframes show content and states. They imply no layout.

Claims live in [the spec](../spec/v1.0.md). A screen must keep every claim listed for it.

### W1 Catalog, nothing ticked

Wireframe: [web-01-catalog-empty.html](wireframes/web-01-catalog-empty.html)

- Purpose. Let the person find and tick apps.
- Content. All 44 apps in 9 categories, each as an icon and a name. The categories are Browsers, Communication, Developer tools, Media, Creative, Productivity and storage, Games, Security and Utilities. The full list is the "Catalog list" section of [the spec](../spec/v1.0.md#catalog-list). The page also needs the Settlein name and a short line saying what it does.
- States. Nothing ticked. An app on hover, on keyboard focus and ticked. The sticky bar when the count is zero.
- Actions. Tick and untick an app. Reach the download button.
- Claims. [C6](../spec/v1.0.md) one page, icon and name, grouped by category. [C9](../spec/v1.0.md) the sticky bar. [C10](../spec/v1.0.md) light and dark. [C11](../spec/v1.0.md) no ads. [C12](../spec/v1.0.md) no Terminal command. [C13](../spec/v1.0.md) no cookie.

### W2 Catalog, apps ticked

Wireframe: [web-02-catalog-selected.html](wireframes/web-02-catalog-selected.html)

- Purpose. Show the selection and offer the download.
- Content. The same grid with ticked apps marked. A bar that stays visible while the page scrolls, with the count of ticked apps and the download button.
- States. One app ticked. Many ticked. A page opened from an address that names apps, with those apps already ticked. An address that names an app the catalog does not hold, which the page ignores without an error.
- Actions. Tick, untick, download.
- Claims. [C7](../spec/v1.0.md) the address holds the ticked names. [C8](../spec/v1.0.md) an address with names opens with them ticked. [C9](../spec/v1.0.md) the bar stays visible and shows the right count and the button. [C10](../spec/v1.0.md), [C11](../spec/v1.0.md), [C12](../spec/v1.0.md).

### W3 After the download click

Wireframe: [web-03-after-download.html](wireframes/web-03-after-download.html)

The spec leaves this screen open. See the open questions. Design what a person needs after the click, and keep the claims. It cannot show a Terminal command ([C12](../spec/v1.0.md)). The wireframe holds our starting guess only.

- Purpose. Tell the person what to do next.
- Content. Open to your design, within the claims.
- States. Download started. The person has Settlein installed, so the app opens instead.
- Claims. [C12](../spec/v1.0.md), [C15](../spec/v1.0.md), [C17](../spec/v1.0.md).

### A1 Confirmation

Wireframe: [app-01-confirmation.html](wireframes/app-01-confirmation.html)

- Purpose. Let the person check the list and approve it. This is the guard against a link that names the wrong apps.
- Content. Every selected app with its icon and name. An "already installed" mark on apps that are already on the Mac. A mark on pkg apps that says the app opens in Apple's Installer. An approve button and a cancel button.
- States. A mix of new, already installed and pkg apps. Every app already installed. A long selection that scrolls.
- Actions. Approve. Cancel.
- Claims. [C15](../spec/v1.0.md) the screen lists exactly the ticked apps. [C17](../spec/v1.0.md) the same on a later visit. [C18](../spec/v1.0.md) nothing downloads before approve. [C21](../spec/v1.0.md) pkg apps open in Apple's Installer. [C25](../spec/v1.0.md) already installed apps are marked and left unchanged. [C27](../spec/v1.0.md) no data is sent.

### A2 Installing

Wireframe: [app-02-installing.html](wireframes/app-02-installing.html)

- Purpose. Show progress for every app.
- Content. One row per app with a status. The statuses are waiting, downloading, verifying, installing, done and refused. A refused row names the app and the reason. A pkg app that is open in Apple's Installer shows a "waiting in Apple's Installer" status.
- States. Each status on its own. A run with one refused app while the others continue. A signature refusal and a checksum refusal, which carry different reasons.
- Actions. None are required. You may propose a cancel control, and say what it does.
- Claims. [C19](../spec/v1.0.md) every app installs with no vendor site or Terminal. [C20](../spec/v1.0.md) no password prompt for copy apps. [C21](../spec/v1.0.md) pkg apps. [C22](../spec/v1.0.md) a refusal for a missing signature names the app and the reason. [C23](../spec/v1.0.md) a refusal for a checksum mismatch names the app and the reason.

### A3 Finished

Wireframe: [app-03-finished.html](wireframes/app-03-finished.html)

- Purpose. Say what happened.
- Content. Counts and lists of installed, skipped (already installed) and refused apps. Each refused app keeps its name and reason. A way to reach the installed list and a way to close Settlein.
- States. All installed. Some skipped. Some refused. Everything refused.
- Actions. Close. Open the installed list.
- Claims. [C19](../spec/v1.0.md), [C22](../spec/v1.0.md), [C23](../spec/v1.0.md), [C25](../spec/v1.0.md).

### A4 Installed list

Wireframe: [app-04-installed-list.html](wireframes/app-04-installed-list.html)

- Purpose. Show the apps Settlein installed and let the person remove them.
- Content. A list of apps Settlein installed, each with an uninstall control. It shows no app that the person installed by hand.
- States. Empty list. A list with copy and pkg apps. A pkg app should signal that removal asks for the admin password.
- Actions. Uninstall one app.
- Claims. [C28](../spec/v1.0.md).

### A5 Uninstall

Wireframe: [app-05-uninstall.html](wireframes/app-05-uninstall.html)

- Purpose. Confirm a removal, show progress and show the result.
- Content. A confirmation that names the app and says its leftovers go with it. A progress state. A result that says what was removed, or why a removal failed.
- States. Copy app. Pkg app, where macOS shows one admin password prompt. The person cancels the prompt. A standard user with no admin password cannot remove a pkg app, so the screen needs an explanation for that case.
- Actions. Confirm. Cancel. Close.
- Claims. [C29](../spec/v1.0.md) a copy app loses its bundle and leftovers. [C30](../spec/v1.0.md) a pkg app asks for the password once. [C31](../spec/v1.0.md) only paths the catalog lists are deleted.
- The password prompt is system UI. Do not design it. Design the screen around it.

### A6 Catalog unreachable

Wireframe: [app-06-catalog-unreachable.html](wireframes/app-06-catalog-unreachable.html)

The spec does not cover this state. It is realistic, because the app reads the catalog only from settlein.dev ([C5](../spec/v1.0.md)) and the person may be offline.

- Purpose. Tell the person the catalog did not load.
- Content. What failed, in plain words, and what to do next. No Terminal command.
- States. Offline. The site answers with an error.
- Actions. Try again. Close.
- Claims. [C5](../spec/v1.0.md), [C12](../spec/v1.0.md) applies in spirit to the app too.

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
- Claims. [C12](../spec/v1.0.md), [C32](../spec/v1.0.md).

## System UI you cannot change

Do not mock these as ours. Show a placeholder frame if a screen needs to depict the moment.

- The Gatekeeper first-open dialog with its Open button ([C32](../spec/v1.0.md)). Settlein is signed and notarized, so macOS shows only its standard dialog.
- The browser's prompt to allow opening Settlein from a web link. It appears the first time a person clicks the download button with Settlein installed ([S3](../spec/v1.0.md#spec-assumptions)).
- The macOS admin password prompt, which appears once when the person removes a pkg app ([C30](../spec/v1.0.md)).
- Apple's Installer, which opens for each pkg app ([C21](../spec/v1.0.md)).
- Sparkle's update window, which offers a new version of Settlein ([C33](../spec/v1.0.md)).

## What is fixed and what is open

[ADR-0023](../adr/0023-designer-returns-figma-and-design-md.md) records this split.

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

- The Mac app is SwiftUI on macOS 26 and 27, on Apple silicon ([C26](../spec/v1.0.md)). It should look native on both.
- The website follows the system's light or dark appearance ([C10](../spec/v1.0.md)). Design both themes. Do not add a theme switch unless you tell us why.
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

We have not settled these. Design a sensible answer, and mark it in Figma so we can change it.

1. How does a person reach the installed list (A4)? Opening Settlein with no selection sends them to the website ([C16](../spec/v1.0.md)). The list needs another way in, such as a menu bar item, a link on A3 or a link on the website.
2. What does W3 show after the download click? The spec says nothing about it.
3. What should the app do while a pkg app waits in Apple's Installer? Settlein cannot tell whether the person finished or cancelled ([ADR-0005](../adr/0005-copy-apps-and-open-pkg-installers.md)), so A2 and A3 may need a state for "check the result".
4. What does a person see when a link names an app the catalog no longer holds ([ADR-0009](../adr/0009-selection-lives-in-the-url.md))? W2 ignores it for now.
5. What does a standard user see when they try to remove a pkg app? They have no admin password ([ADR-0010](../adr/0010-admin-password-to-remove-pkg-apps.md)).
