# Settlein app

SwiftUI app for Apple silicon on macOS 26 and later. This shell fetches the catalog and shows the confirmation screen. Approve downloads nothing yet.

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
open -n Settlein.app --args -catalogFile /path/to/catalog.json -selection "Google Chrome,Firefox,Tailscale"
```

`-selection` takes catalog app names separated by commas. Names the catalog does not hold are dropped. With no `-catalogFile` the app requests `https://settlein.dev/catalog.json` and nothing else.
