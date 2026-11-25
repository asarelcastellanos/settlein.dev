# Settlein app

SwiftUI app for Apple silicon on macOS 26 and later. This app fetches the catalog, shows the confirmation screen, and installs the approved copy apps. Pkg apps show "Not built yet" until issue #11.

## Build

Needs Xcode and XcodeGen.

```sh
cd app
xcodegen generate
xcodebuild -project Settlein.xcodeproj -scheme Settlein -configuration Debug build
```

## Run with a development catalog and selection

Debug builds accept two launch arguments. Release builds ignore them.

```sh
open -n Settlein.app --args -catalogFile /path/to/catalog.json -selection "google-chrome,firefox,tailscale"
```

`-selection` takes Homebrew cask tokens separated by commas. Tokens the catalog does not hold are dropped. With no `-catalogFile` the app requests `https://settlein.dev/catalog.json` and nothing else.
