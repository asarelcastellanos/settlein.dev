# SettleIn app

SwiftUI app for Apple silicon on macOS 26 and later. This app fetches the catalog and opens Pick apps, the installed list or the Installing screen, as ADR-0035 sets out. It installs copy apps and opens pkg apps in Apple's Installer. Pkg apps are downloaded and verified, then opened in Apple's Installer for the person. The opened package stays in a `settlein-pkg-*` folder in the temporary folder. SettleIn removes folders older than 24 hours when the next run starts.

## Build

Needs Xcode and XcodeGen.

```sh
cd app
xcodegen generate
xcodebuild -project SettleIn.xcodeproj -scheme SettleIn -configuration Debug build
```

## Run with a development catalog and selection

Debug builds accept five launch arguments. Release builds ignore them.

```sh
open -n SettleIn.app --args -catalogFile /path/to/catalog.json -selection "google-chrome,firefox,tailscale-app" -recordFile /path/to/installs.json -iconBase /path/to/website/public/icons
```

`-iconBase` is a folder of `<token>-256.png` files. SettleIn reads icons from it and skips the network and the disk cache, and a missing file or folder shows letter tiles. With no `-iconBase` the app requests `https://settlein.dev/icons/<token>-256.png` and caches each icon in `~/Library/Caches/SettleIn/icons` (ADR-0041).

`-selection` takes catalog `token` values, which are Homebrew cask tokens, separated by commas. Tokens the catalog does not hold are dropped. With a selection, SettleIn starts installing at once. `-recordFile` replaces `~/Library/Application Support/SettleIn/installs.json`, the record of what SettleIn installed (ADR-0040). `-catalogURL <url>` fetches the catalog from that URL instead of settlein.dev, and `-catalogFile` wins when both are set. Use `-catalogURL https://catalog.invalid/catalog.json` to simulate an offline Mac, because the name never resolves and the app shows the offline screen. Use `-catalogURL http://127.0.0.1:<port>/catalog.json` against a local server that returns 500 to simulate a settlein.dev failure. A host that does not answer, such as `https://10.255.255.1/catalog.json`, times out after 15 seconds and shows the site-error screen. Never turn off Wi-Fi to test it. With neither argument the app requests `https://settlein.dev/catalog.json` and nothing else.
