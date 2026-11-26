# Every screen, every state

Each screen against four states: empty, loading, error, success. Every cell names the board on the canvas and its screenshot in `screenshots/`. "n/a" means the state can't happen, with the reason. Rows marked **(new)** were added in this hand-off; rows marked *proposal* are not in the brief.

## Website

| Screen | Empty | Loading | Error | Success |
|---|---|---|---|---|
| W1 Home picker (desktop) | Nothing ticked: `website/Catalog.png`, Web-States "Nothing ticked yet" | Icons not yet loaded: Web-States "Picker before icons arrive" **(new)** | Link names unknown apps: W2 `website/W2-link.png` · JavaScript off: Web-States **(new, proposal)** | Apps ticked, Download showing: `website-1440/02-home-picked.png` |
| W1 Home (phone, 375) | `mobile/Catalog-m.png`, Web-States "Nothing ticked on a phone" | Same as desktop: icon slots stay plain | Clipboard blocked: Web-States "Couldn't copy" **(new, proposal)** | `mobile/Catalog-m-picked.png` + Web-States "Link copied" **(new)** |
| W2 Home from a link | Every app unknown: notice + empty picker (described on Web-States) | n/a: the list is in the page | One or more unknown: `website/W2-link.png` | Every app known: same as W1 success |
| W3 After the download click | n/a: only reached with a selection | n/a: the browser's own download bar shows progress | Download didn't start: Web-States **(new, proposal)** | `website/After.png` |
| Release notes | Filter tab with no entries (Notices at launch): `website/Releases-notices-empty.png` **(new)** | n/a: static page | n/a: static page | `website/Releases.png`, later: `website/Releases-example.png` |
| How apps are verified / What SettleIn sends | n/a: static | n/a | n/a | `website/Verify.png`, `website/Privacy.png` |

## Mac app

| Screen | Empty | Loading | Error | Success |
|---|---|---|---|---|
| D1 Disk image | n/a | n/a: Finder | macOS damaged-file alert: system UI, out of scope | `mac/M-D1.png` |
| A7 Pick apps | Nothing ticked: `mac/M-P1c.png` | Catalog loading: `mac/M-P1d.png` **(new)** | Catalog unreachable: A6 | Apps ticked: `mac/M-P1a.png` |
| A2 Installing | Nothing to install: `mac/M-A2e.png` | Downloading / verifying rows: `mac/M-A2a.png` | Refused (two reasons): `mac/M-A2b.png` · Download failed: row state, see `diagrams/d-03` | Ends on A3 |
| A2 panels | n/a | n/a | n/a | Cancel: `mac/M-A2c.png` · Change selection: `mac/M-A2d.png` |
| A3 Finished | n/a: A2e handles "nothing" | n/a | Everything refused: `mac/M-A3c.png` · Mixed: `mac/M-A3a.png` | All installed: `mac/M-A3b.png` |
| A4 Installed list | `mac/M-A4b.png` | `mac/M-A4c.png` **(new)** | Record unreadable: `mac/M-A4d.png` **(new, proposal)** | `mac/M-A4a.png` |
| A5 Uninstall | n/a | Removing: `mac/M-A5d.png` · Password: `mac/M-A5c.png` | Prompt cancelled: `mac/M-A5f.png` · Failed: `mac/M-A5g.png` · Standard user: `mac/M-A5h.png` | `mac/M-A5e.png` |
| A6 Catalog unreachable | n/a | Retrying: `mac/M-A6c.png` | Offline: `mac/M-A6a.png` · Site error: `mac/M-A6b.png` | Leaves for the screen launch logic picks |
| A0 Menu bar | n/a | n/a | n/a | `mac/M-Menu.png` |
| Check for Updates (Sparkle) | Up to date | Checking | Can't check | Update available → install → relaunch |

Sparkle's own standard windows cover Check for Updates; SettleIn doesn't restyle them. The feed URL and EdDSA key are in the release checklist, not in the design.

## Rules for every state

- Loading UI appears only after 300 ms. Below that, show nothing, so fast networks never flash.
- Errors say what happened, then what the person can do, in one sentence each. There are no error codes on screen; log them instead.
- An error never clears the person's selection.
- Every state with a button has one primary action and at most one other.
