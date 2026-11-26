# Scripts

## release.sh

Builds, signs, notarizes and packs the SettleIn release (claim C32).

```sh
scripts/release.sh app
scripts/release.sh /path/to/SettleIn.app
```

The argument is the app source folder (the one holding `project.yml`) or a built `.app`. A source folder builds the Release configuration with XcodeGen and xcodebuild. The script signs with the Developer ID and hardened runtime, notarizes and staples the app, packs a plain `SettleIn.dmg` (ADR-0018), then notarizes and staples the disk image. It stops on the first failed step and removes its work folder.

Needs a Developer ID Application certificate in the login keychain and a notarytool keychain profile named `settlein`. Set `SIGN_IDENTITY` or `NOTARY_PROFILE` to override them. `OUT_DIR` sets the output folder, `./release` by default. `SettleIn.app` and `SettleIn.dmg` land there only after every step passes. The outputs are not committed.
