# Retro: Settlein v1.0 build, first session

2026-11-24. The owner typed `/retro` after Foundation, Test build and Catalog merged into `release/v1.0`.

## Earlier ledgers

[2026-11-24-settlein-planning.md](2026-11-24-settlein-planning.md) picked five fixes. Each became an open issue on `asarelcastellanos/studio-201`.

| Pick | Issue | Graded |
|---|---|---|
| Fix the policy hook's test for "editing code" | [#315](https://github.com/asarelcastellanos/studio-201/issues/315) | Not fixed. The hook refused the same kind of command again this session (`rm`, `mv` and `cp` of test leftovers, a heredoc `--body-file`, a Python edit in the memory folder, a heredoc that wrote scratchpad `.md` files). |
| Let the researcher run read-only Bash | [#316](https://github.com/asarelcastellanos/studio-201/issues/316) | No evidence. No researcher ran this session. |
| Owner-chosen lists need item approval | [#317](https://github.com/asarelcastellanos/studio-201/issues/317) | No evidence. No list entered the spec this session. |
| Plan template takes the project name | [#318](https://github.com/asarelcastellanos/studio-201/issues/318) | No evidence. No plan page was built. |
| Count a list by command | [#319](https://github.com/asarelcastellanos/studio-201/issues/319) | No evidence. |

## Candidates

| # | Candidate | Kind | Scope | Form | Moment | Owner's answer |
|---|---|---|---|---|---|---|
| 1 | Add this session's refusals as evidence on studio-201 #315. | check | Studio 201 | add (repair of an existing check) | The hook refused `rm`, `mv` and `cp` of test leftovers, so the owner deleted them by hand. It also refused a `--body-file` written in the same command. | Picked. [Comment posted](https://github.com/asarelcastellanos/studio-201/issues/315#issuecomment-7146962849). |
| 2 | `studio-201:git-flow` checks `delete_branch_on_merge` and turns it on. | check | Studio 201 | add | AGENTS.md says merged branches are deleted, but the setting was off. A multi-branch `git push --delete` returned 500. | Picked. [studio-201 #333](https://github.com/asarelcastellanos/studio-201/issues/333). |
| 3 | AGENTS.md line: in zsh, brace every variable next to a colon or word, as `${c}`. | pointer | Studio 201 | add | `"$c:refs/..."` applied the zsh `:r` modifier and a refspec failed. The planning session also hit a zsh word-split bug. | Asked first because a pointer was rejected before. Picked. [studio-201 #334](https://github.com/asarelcastellanos/studio-201/issues/334). |
| 4 | A claim that reads a protected folder names the macOS prompt it triggers. | standards line | this project | add | The owner said "did not ask for downloads folder" when the test app's Downloads scan raised a prompt. | Picked. Added to `CODING_STANDARDS.md`. |
| 5 | Every UI action shows a result or an error. | standards line | this project | add | The owner said "install and remove test app does nothting" when the S8 button gave no feedback. | Rejected. |

## Picks

Candidates 1 to 4.

## Rejections

Candidate 5, kind standards line.

## Note for the build

ADR-0019 has the app read `Settlein.dmg` files in Downloads. That read raises the same Downloads prompt the test app raised. The handoff issue must name it under candidate 4's line.
