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

if [[ "$input" == *.app ]]; then
  [ -d "$input" ] && [ -f "$input/Contents/Info.plist" ] || { echo "Not an app bundle (needs Contents/Info.plist): $input" >&2; exit 2; }
else
  [ -f "$input/project.yml" ] || { echo "No project.yml in $input" >&2; exit 2; }
fi

matches=$(security find-identity -v -p codesigning | { grep -F "$identity" || true; } | awk '{print $2}' | sort -u | wc -l | tr -d ' ')
[ "$matches" = 1 ] || { echo "Signing identity '$identity' matches $matches certificates, need exactly 1" >&2; exit 2; }
xcrun notarytool history --keychain-profile "$profile" >/dev/null || { echo "Notary profile '$profile' does not work" >&2; exit 2; }

out_created=0
[ -d "$out" ] || out_created=1
mkdir -p "$out"
out=$(cd "$out" && pwd)

work=""
cleanup() {
  status=$?
  if [ -n "$work" ]; then
    rm -rf "$work"
  fi
  if [ "$status" -ne 0 ] && [ "$out_created" = 1 ]; then
    rm -rf "$out"
  fi
}
trap cleanup EXIT
work=$(mktemp -d "$out/.work.XXXXXX")

notarize() {
  local result
  result=$(xcrun notarytool submit "$1" --keychain-profile "$profile" --wait --output-format json)
  echo "$result"
  [ "$(echo "$result" | plutil -extract status raw -o - -)" = "Accepted" ] || { echo "Notarization status is not Accepted: $1" >&2; exit 1; }
}

if [[ "$input" == *.app ]]; then
  ditto "$input" "$work/Settlein.app"
else
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
notarize "$work/notarize-app.zip"
xcrun stapler staple "$app"
xcrun stapler validate "$app"

mkdir "$work/dmg-root"
ditto "$app" "$work/dmg-root/Settlein.app"
hdiutil create -volname "Settlein" -srcfolder "$work/dmg-root" -ov -format UDZO "$work/Settlein.dmg"
codesign --force --timestamp --sign "$identity" "$work/Settlein.dmg"
notarize "$work/Settlein.dmg"
xcrun stapler staple "$work/Settlein.dmg"
xcrun stapler validate "$work/Settlein.dmg"

spctl -a -vv "$app"
spctl -a -t open --context context:primary-signature -vv "$work/Settlein.dmg"

rm -rf "$out/Settlein.app" "$out/Settlein.dmg"
mv "$app" "$out/Settlein.app"
mv "$work/Settlein.dmg" "$out/Settlein.dmg"
