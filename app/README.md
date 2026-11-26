# SettleIn app

SwiftUI app for Apple silicon on macOS 26 and later. This app fetches the catalog, shows the confirmation screen, and installs the approved copy apps. Pkg apps are downloaded and verified, then opened in Apple's Installer for the person. The opened package stays in a `settlein-pkg-*` folder in the temporary folder. SettleIn removes folders older than 24 hours when the next run starts.

## Build

Needs Xcode and XcodeGen.

```sh
cd app
xcodegen generate
xcodebuild -project SettleIn.xcodeproj -scheme SettleIn -configuration Debug build
```

## Run with a development catalog and selection

Debug builds accept two launch arguments. Release builds ignore them.

```sh
open -n SettleIn.app --args -catalogFile /path/to/catalog.json -selection "google-chrome,firefox,tailscale-app"
```

`-selection` takes catalog `token` values, which are Homebrew cask tokens, separated by commas. The confirmation screen marks pkg apps such as `tailscale-app` as opening Apple's Installer. Tokens the catalog does not hold are dropped. With no `-catalogFile` the app requests `https://settlein.dev/catalog.json` and nothing else.
