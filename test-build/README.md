# Test build

A throwaway signed app and a local download server. They settle spec assumptions S1, S2 and S8. Nothing here ships.

## Build

Needs Xcode command line tools, a Developer ID Application certificate in the login keychain and a notarytool keychain profile named `settlein`.

```sh
test-build/build.sh
```

The script compiles the app, signs it with the hardened runtime, notarizes and staples it, then packs `build/Settlein.dmg` and `build/Settlein.zip`. It notarizes the app and the disk image. Set `SIGN_IDENTITY` or `NOTARY_PROFILE` to override the defaults. The outputs sit in `test-build/build/` and are not committed.

## Serve

```sh
test-build/serve.py
```

Open `http://localhost:8080/?apps=firefox,raycast,vlc` in Safari or Chrome. The page links to `/Settlein.dmg?apps=...` and `/Settlein.zip?apps=...`. The server sends `Content-Disposition: attachment; filename="Settlein-<apps>.dmg"`, so the selection sits in both the file name and the origin URL. Allowed selection characters are `a-z`, `0-9`, `-` and commas.

## QA matrix

Run on a macOS 27 user account that never ran the app. Do not grant Settlein Test the App Management permission.

For each of Safari and Chrome, and for each of the disk image and the zip:

1. Start the server and download from the page.
2. Open the app from the mounted disk image (disk image) or from the Downloads folder (zip). Click Open in the first-open dialog.
3. Copy the report from the window or from `~/Library/Logs/SettleinTestBuild/report-<time>.txt`.

S1 passes when "selection from file name" or "selection from kMDItemWhereFroms" shows `firefox,raycast,vlc` on a candidate. S2 passes when a candidate lists that file and "content read" says ok. Also open the disk image app after copying it to Downloads, and note any Files and Folders prompt for Downloads.

S8: in one run, click "Install and remove test app". It downloads AppCleaner, installs it in `/Applications`, then removes it. S8 passes when the report says `remove: ok` and no App Management prompt appears. Check System Settings, Privacy and Security, App Management does not list Settlein Test.

The test app is AppCleaner 3.7 from the Homebrew cask `appcleaner`. It is free, small, signed by another developer (Team ID in the report) and installs by copying one `.app`, the install type ADR-0005 supports. macOS guards bundles from other developers, so a bundle the test built itself would pass for the wrong reason.
