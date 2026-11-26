# SettleIn

SettleIn sets up a new Mac. You open settlein.dev, tick the apps you want and download SettleIn. SettleIn shows the list, waits for your approval, then downloads, verifies and installs every app. It needs no Terminal and no visits to vendor websites. It also removes the apps it installed, with their leftovers.

The repository holds the Mac app (Swift), the website (HTML, CSS and JavaScript) and the app catalog.

## Licence

The code is MIT licensed. See [LICENSE](LICENSE).

## Checks

Run both checks from the repository root before you open a pull request.

```sh
scripts/check-comments.sh
scripts/check-skills.sh
```

`check-comments.sh` fails if your changes add a code comment to a Swift, shell, HTML, CSS or JavaScript file. It compares your branch with the remote default branch, or with the branch you pass as an argument. `check-skills.sh` checks the files in `skills/`. It passes when that folder does not exist.

GitHub Actions runs both checks on every pull request.
