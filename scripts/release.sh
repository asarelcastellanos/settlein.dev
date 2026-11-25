#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: release.sh <app source folder | built .app>" >&2
  echo "Env: SIGN_IDENTITY, NOTARY_PROFILE, OUT_DIR (default ./release)" >&2
  exit 2
fi

input="${1%/}"
identity="${SIGN_IDENTITY:-Developer ID Application}"
profile="${NOTARY_PROFILE:-settlein}"
out="${OUT_DIR:-$PWD/release}"

[ -e "$input" ] || { echo "Not found: $input" >&2; exit 2; }
input=$(cd "$(dirname "$input")" && pwd)/$(basename "$input")
mkdir -p "$out"
out=$(cd "$out" && pwd)

work=$(mktemp -d "$out/.work.XXXXXX")
trap 'rm -rf "$work"' EXIT

if [[ "$input" == *.app ]]; then
  ditto "$input" "$work/Settlein.app"
else
  [ -f "$input/project.yml" ] || { echo "No project.yml in $input" >&2; exit 2; }
  ditto "$input" "$work/src"
  (cd "$work/src" && xcodegen generate --quiet)
  xcodebuild -project "$work/src/Settlein.xcodeproj" -scheme Settlein \
    -configuration Release -derivedDataPath "$work/derived" \
    CODE_SIGNING_ALLOWED=NO build
  ditto "$work/derived/Build/Products/Release/Settlein.app" "$work/Settlein.app"
fi
app="$work/Settlein.app"

codesign --force --options runtime --timestamp --sign "$identity" "$app"
codesign --verify --strict --verbose=2 "$app"

ditto -c -k --keepParent "$app" "$work/notarize-app.zip"
xcrun notarytool submit "$work/notarize-app.zip" --keychain-profile "$profile" --wait
xcrun stapler staple "$app"
xcrun stapler validate "$app"

mkdir "$work/dmg-root"
ditto "$app" "$work/dmg-root/Settlein.app"
hdiutil create -volname "Settlein" -srcfolder "$work/dmg-root" -ov -format UDZO "$work/Settlein.dmg"
codesign --force --timestamp --sign "$identity" "$work/Settlein.dmg"
xcrun notarytool submit "$work/Settlein.dmg" --keychain-profile "$profile" --wait
xcrun stapler staple "$work/Settlein.dmg"
xcrun stapler validate "$work/Settlein.dmg"

rm -rf "$out/Settlein.app" "$out/Settlein.dmg"
mv "$app" "$out/Settlein.app"
mv "$work/Settlein.dmg" "$out/Settlein.dmg"

spctl -a -vv "$out/Settlein.app"
spctl -a -t open --context context:primary-signature -vv "$out/Settlein.dmg"
