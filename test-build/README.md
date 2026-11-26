# Test build

A throwaway signed app and a local download server. They settle spec assumptions S1, S2 and S8. Nothing here ships.

## Build

Needs Xcode command line tools, a Developer ID Application certificate in the login keychain and a notarytool keychain profile named `settlein`.

```sh
test-build/build.sh
```

The script compiles the app, signs it with the hardened runtime, notarizes and staples it, then packs `build/SettleIn.dmg`. It notarizes the app and the disk image. Set `SIGN_IDENTITY` or `NOTARY_PROFILE` to override the defaults. The outputs sit in `test-build/build/` and are not committed.

## Serve

```sh
test-build/serve.py
```

Open `http://localhost:8080/?apps=iterm2,rectangle,obsidian` in Safari or Chrome. The page links to `/SettleIn.dmg?apps=...`. The server sends `Content-Disposition: attachment; filename="SettleIn.dmg"`, so the file name names no apps and the selection sits only in the download URL (ADR-0018). Allowed selection characters are `a-z`, `0-9`, `-` and commas.

## QA matrix

Run on a macOS 27 user account that never ran the app. Do not grant SettleIn Test the App Management permission.

For each of Safari and Chrome:

1. Start the server and download from the page.
2. Open the app from the mounted disk image. Click Open in the first-open dialog.
3. Copy the report from the window or from `~/Library/Logs/SettleInTestBuild/report-<time>.txt`.
4. In Finder, select the downloaded file, press Command-I and note what Get Info shows under "Where from".

S1 passes when the "S1 selection from download URL" line in the block under "S2 launched file" shows `iterm2,rectangle,obsidian`. The same line in an "other candidates" block does not count. It reads only `kMDItemWhereFroms[0]`, the download URL. The report still prints every where-from entry raw. The file name must be `SettleIn.dmg` or `SettleIn (N).dmg`, where N is a number. Record the "Where from" text for every run, including runs where S1 fails. S2 passes when the "S2 launched file" line names this launch's image and its "content read" says ok. The report ties that line to the launch through the `hdiutil` mount match or the translocation original path. It lists every other candidate under "other candidates (not used for S2)", and those do not count. The Downloads scan matches only those two file names. Also open the disk image app after copying it to Downloads, and note any Files and Folders prompt for Downloads.

S8: in one run, click "Install and remove test app". It downloads AppCleaner, checks the SHA-256 and unzip, installs it in `/Applications`, then removes it. If `/Applications` is not writable, the report says "S8 not run: /Applications not writable by this user" and nothing installs. If the SHA-256 or unzip fails, the step stops before install. If the copy fails partway, the step removes the partial bundle it created. S8 passes when the report says `remove: ok` for `/Applications/AppCleaner.app` and no App Management prompt appears. Check System Settings, Privacy and Security, App Management does not list SettleIn Test.

The test app is AppCleaner 3.7 from the Homebrew cask `appcleaner`. It is free, small, signed by another developer (Team ID in the report) and installs by copying one `.app`, the install type ADR-0005 supports. macOS guards bundles from other developers, so a bundle the test built itself would pass for the wrong reason.
