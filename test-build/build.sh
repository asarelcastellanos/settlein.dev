#!/bin/bash
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
out="$here/build"
name="SettleIn Test"
identity="${SIGN_IDENTITY:-Developer ID Application}"
profile="${NOTARY_PROFILE:-settlein}"
app="$out/$name.app"

rm -rf "$out"
mkdir -p "$app/Contents/MacOS" "$out/dmg-root"

swiftc -O -parse-as-library -swift-version 5 \
  -target arm64-apple-macos13.0 \
  -o "$app/Contents/MacOS/SettleInTest" \
  "$here"/app/Attributes.swift "$here"/app/Locator.swift "$here"/app/Report.swift \
  "$here"/app/Install.swift "$here"/app/TestBuildApp.swift
cp "$here/app/Info.plist" "$app/Contents/Info.plist"

codesign --force --options runtime --timestamp --sign "$identity" "$app"
codesign --verify --strict --verbose=2 "$app"

ditto -c -k --keepParent "$app" "$out/notarize-app.zip"
xcrun notarytool submit "$out/notarize-app.zip" --keychain-profile "$profile" --wait
xcrun stapler staple "$app"

ditto "$app" "$out/dmg-root/$name.app"
hdiutil create -volname "$name" -srcfolder "$out/dmg-root" -ov -format UDZO "$out/SettleIn.dmg"
codesign --force --timestamp --sign "$identity" "$out/SettleIn.dmg"
xcrun notarytool submit "$out/SettleIn.dmg" --keychain-profile "$profile" --wait
xcrun stapler staple "$out/SettleIn.dmg"

rm -rf "$out/dmg-root" "$out/notarize-app.zip"

spctl -a -vv "$app"
xcrun stapler validate "$app"
xcrun stapler validate "$out/SettleIn.dmg"
spctl -a -t open --context context:primary-signature -vv "$out/SettleIn.dmg"
