# SettleIn copy deck (COPY.md)

Every string on every screen, in order. Sentence case everywhere, with curly apostrophes and quotes. "SettleIn" always has a capital I.

Square brackets mark placeholders to fill: [DATE], [VERSION], [APP NAME], [URL].

## Voice

- Short sentences, one idea each. Stack them; don’t chain them with commas.
- Say what happened, then what the person can do.
- Name the app and the reason. Never "an error occurred".
- No exclamation marks, no "Oops", no "simply" or "just".
- Use Apple’s words for Apple things: Applications, Trash, Apple’s Installer, admin password.

## Website

### Header and footer (every page)
- SettleIn · GitHub ↗
- SettleIn: "Sets up your new Mac in one go. Free and open source."
- Star SettleIn on GitHub ↗
- Footer columns: **SettleIn**: Release notes · **Open source**: Source code ↗, Report a problem ↗, Suggest an app ↗ · **Trust**: How apps are verified, What SettleIn sends
- © 2026 SettleIn contributors
- Not affiliated with Apple. App names and icons belong to their owners.

### W1 Home: hero
- Your new Mac, / Settled In.  *(two lines; "Your new Mac," never wraps)*
- SettleIn installs every app, all in one go.
- Select from a curated set.
- We verify the signature.
- Uninstall whenever you want.
- Choose your apps ↓ · Play demo / Pause demo

### W1 Home: demo window (decorative, aria-hidden)
- Choose your apps · Installing 5 apps · N of 5 done · Checking [APP] · Developer ID signature · Notarized by Apple · SHA-256 matches the catalog
- Waiting · Downloading · Verifying · Done · Opened in Apple’s Installer
- Installed by SettleIn · Uninstall removes the app and its leftovers. · Uninstall · Removing leftovers…
- N apps selected · Download SettleIn

### W1 Home: picker
- Pick the apps for your Mac.
- Select all · Deselect all  *(page-wide)*
- [Category] · Select all / Deselect all  *(per category)*
- Categories: Browsers, Communication, Developer tools, Media, Creative, Productivity and storage, Games, Security, Utilities
- Bar: 0 apps selected · Tick an app above to start
- Bar: 1 app selected / N apps selected · Download SettleIn
- Phone intro: SettleIn runs on a Mac. Pick your apps here, copy the link, and open it on your Mac.
- Phone bar: Tick apps, then copy the link for your Mac · Copy link · Link copied
- Phone error: Couldn’t copy. Press and hold the link to copy it.  *(proposal)*
- No JavaScript: Turn on JavaScript to pick apps here, or download SettleIn and pick inside the app.  *(proposal)*

### W2 Home from a link
- This link named 1 app SettleIn no longer offers, so it was left out.
- This link named N apps SettleIn no longer offers, so they were left out.
- Dismiss

### W3 After the download click
- Your download has started.
- Apps in this download
- Change selection · Download again
- Already have SettleIn? It opens by itself with this list. If your browser asks, choose Allow.
- Error *(proposal)*: The download didn’t start. / GitHub, where SettleIn is hosted, didn’t answer. / Your choices are saved in this page’s address. / Try again · Get it from GitHub

### Release notes
- Release notes
- Two things change: the SettleIn app, which updates itself, and the catalog of apps on settlein.dev, which changes without an app update. Both are listed here, newest first.
- Tabs: Everything · App updates · Catalog changes · Notices
- Entry labels: App update · Catalog change · Notice
- Empty tab: Nothing here yet. / Notices appear when an app is paused or changed for safety.
- App updates also show inside SettleIn when they arrive. Follow changes with RSS · All releases on GitHub
- Launch entry and later examples: see `screenshots/website/Releases.png` and `Releases-example.png` for the full text.

### How apps are verified · What SettleIn sends
Full text on the boards: `screenshots/website/Verify.png` and `Privacy.png`. Sentences are stacked, one per line.

## Mac app




### A0 Menu bar

- File
- Edit
- Apps
- Window
- Help
- About SettleIn
- Check for Updates…
- Hide SettleIn  ⌘H
- Hide Others  ⌥⌘H
- Quit SettleIn  ⌘Q
- Pick Apps…  ⌘N
- Installed Apps  ⌘1
- Change Selection…  ⌘E
- Cancel the Rest…  ⌘.
- How SettleIn Checks Apps
- What SettleIn Sends
- Report a Problem…
- settlein.dev
- SettleIn menu
- Apps menu
- Help menu

### D1 Disk image window

- Drag SettleIn to Applications, then open it.
- macOS asks once whether to open it. Click Open.

### A7 Pick apps

- ‹ Installed apps
- Pick apps
- Apps already on this Mac are marked Installed.
- Select all
- Deselect all
- Installed
- 3 apps selected
- Install 3 apps

### A7 Pick apps: nothing ticked

- ‹ Installed apps
- Pick apps
- Apps already on this Mac are marked Installed.
- Select all
- Deselect all
- Installed
- 0 apps selected
- Tick apps to install them

### A7 Pick apps: loading the catalog

- Pick apps
- Loading the catalog from settlein.dev…
- Your choices appear here

### A2 Installing: opens straight into this

- Installing 7 apps
- 2 done · 1 refused · VLC is already on this Mac. You can keep using your Mac.
- Installed in Applications
- Done
- Checking signature and notarization
- Verifying
- Finish the steps in Apple’s Installer, then come back
- Show Installer
- Downloading · 64%
- Downloading
- The download isn’t signed by its developer. Nothing was installed.
- Refused
- Already on this Mac. Left as is.
- Skipped
- Waiting
- Each app downloads from its own developer and is checked before it installs.
- Change selection
- Cancel

### A2 Installing: the two refusal reasons

- Installing 4 apps
- 2 done · 2 refused.
- The download isn’t signed with a valid Developer ID. SettleIn didn’t install it.
- Refused
- The download doesn’t match the checksum in the catalog. It may be damaged or changed. SettleIn didn’t install it.
- Installed in Applications
- Done
- Each app downloads from its own developer and is checked before it installs.
- Change selection
- Cancel

### A2 Installing: cancel

- Installing 7 apps
- 2 done.
- Installed in Applications
- Done
- Checking signature and notarization
- Verifying
- Finish the steps in Apple’s Installer, then come back
- Show Installer
- Downloading · 64%
- Downloading
- The download isn’t signed by its developer. Nothing was installed.
- Refused
- Already on this Mac. Left as is.
- Skipped
- Waiting
- Cancel the rest?
- Visual Studio Code finishes installing, so nothing is left half-installed. The 2 apps still waiting won’t be downloaded. Apps already installed stay.
- Keep installing
- Cancel the rest

### A2 Installing: change selection

- Installing 7 apps
- 2 done.
- Installed in Applications
- Done
- Checking signature and notarization
- Verifying
- Finish the steps in Apple’s Installer, then come back
- Show Installer
- Downloading · 64%
- Downloading
- The download isn’t signed by its developer. Nothing was installed.
- Refused
- Already on this Mac. Left as is.
- Skipped
- Waiting
- Change your selection?
- SettleIn finishes Visual Studio Code and stops there. Then Pick apps opens with your list ticked, so you can add or remove apps and install again.
- Keep installing
- Change selection

### A2 Installing: extra strings (added in the build)

- Installing in Applications
- Opening in Apple’s Installer
- You can keep using your Mac.  *(subtitle before any app is done)*
- Cancelled. Not installed.

### A2 Nothing to install

- Nothing to install
- Every app in this link is already on this Mac, so SettleIn left them as they are.
- Already on this Mac
- Skipped
- Want something else?
- Pick other apps
- Close

### A3 Finished: mixed result

- 3 apps installed
- 1 to check in Apple’s Installer · 1 skipped · 1 refused
- INSTALLED · 3
- Done
- CHECK IN APPLE’S INSTALLER · 1
- SettleIn opened its installer. It can’t tell if you finished.
- Show Installer
- ALREADY ON THIS MAC · 1
- Left as is
- REFUSED · 1
- The download isn’t signed with a valid Developer ID.
- Refused
- Each app runs macOS’s own check the first time you open it.
- Show installed apps

### A3 Finished: all installed

- All 5 apps installed
- Firefox, Slack, Visual Studio Code, Spotify and 1Password are in Applications. Each runs macOS’s own check the first time you open it.
- You can remove any of them later from SettleIn.
- Show installed apps
- Done

### A3 Finished: everything refused

- Nothing was installed
- All 3 apps were refused. Your Mac is unchanged.
- The download isn’t signed with a valid Developer ID.
- Refused
- The download doesn’t match the checksum in the catalog.
- The download isn’t notarized by Apple.
- This usually clears up when the developer fixes their download.
- Report a problem
- Done

### A3 Finished: error line (added in the build)

- SettleIn couldn’t save its record of these apps. They won’t be listed under Installed by SettleIn. Make sure SettleIn’s folder can be written to.

### A3 Finished: extra strings (added in the build)

- [N] apps opened in Apple’s Installer  *(title when only installer-package apps were opened)*
- Nothing was installed  *(title when no app was installed, for example after Cancel)*
- NOT INSTALLED · [N]  *(group for apps skipped by Cancel)*
- Cancelled
- SettleIn couldn’t confirm with Apple that this download is notarized. Check your connection and try again.  *(refusal line when the app has a Developer ID signature but the notarization lookup failed)*
- [N] cancelled  *(part of the subtitle when Cancel skipped apps)*

### A4 Installed list

- Installed by SettleIn
- Only apps SettleIn installed are listed. Uninstalling removes the app and its leftovers.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- 4 apps
- Add apps

### A4 Installed list: empty

- Nothing installed yet
- Pick the apps you want and SettleIn installs them for you.
- Pick apps

### A4 Installed list: loading

- Installed by SettleIn
- Checking which apps are still on this Mac…
- Checking…
- Add apps

### A4 Installed list: record unreadable

- !
- Can’t read the list of installed apps
- SettleIn’s record of what it installed is missing or damaged. Your apps are still installed.
- Show in Finder
- Try again

### A5 Uninstall: confirm

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Uninstall Slack?
- Slack and its leftovers are moved to the Trash:
- /Applications/Slack.app
- ~/Library/Application Support/Slack
- ~/Library/Caches/com.tinyspeck.slackmacgap
- ~/Library/Preferences/com.tinyspeck.slackmacgap.plist
- Example paths; the catalog lists the real ones
- Cancel

### A5 Uninstall: installer-package app

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Uninstall Zoom?
- Zoom, its leftovers and its system files are removed:
- /Applications/zoom.us.app
- ~/Library/Application Support/zoom.us
- /Library/Internet Plug-Ins/ZoomUsPlugIn.plugin
- Example paths; the catalog lists the real ones
- macOS will ask for your admin password once, because some files are in system folders.
- Cancel

### A5 Uninstall: macOS password prompt (system)

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- macOS admin password prompt
- System window, not designed here. Appears once.

### A5 Uninstall: removing

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Removing Slack…
- Moving leftovers to the Trash

### A5 Uninstall: removed

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Slack removed
- 4 items moved to the Trash. Empty the Trash to free the space.
- Done

### A5 Uninstall: password prompt cancelled

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Zoom wasn’t removed
- The password prompt was cancelled, so nothing changed.
- Close
- Try again

### A5 Uninstall: removal failed

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Slack couldn’t be removed
- Slack is still open. Quit it, then try again. Nothing was removed.
- Close
- Try again

### A5 Uninstall: standard user, installer-package app

- Installed by SettleIn
- Only apps SettleIn installed are listed.
- Installed [DATE]
- Uninstall
- Removing asks for your admin password
- Zoom can’t be removed from this account
- Removing Zoom needs an administrator’s password, and this account isn’t an administrator.
- Ask someone with an administrator account to open SettleIn and remove it.

### A6 Catalog unreachable: offline

- Can’t reach the catalog
- This Mac seems to be offline. Check your Wi-Fi or network, then try again.
- Close
- Try again

### A6 Catalog unreachable: site error

- The catalog didn’t load
- settlein.dev answered with an error. Try again in a few minutes.
- Close
- Try again

### A6 Catalog unreachable: retrying

- Trying again…
- Checking settlein.dev.
- Close
- Try again

### System text SettleIn does not write
- The macOS password prompt (A5c) and the Gatekeeper "Open" dialog are Apple’s. Only the `prompt` string passed to Authorization Services is ours: "SettleIn wants to remove [APP NAME] and its leftovers."
- Sparkle’s update windows keep Sparkle’s own wording.

_App names in lists come from the catalog, so they aren’t repeated here. Status lines that name an app are shown with the example app; swap in [APP NAME]._
