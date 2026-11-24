# Retro: Settlein planning session

2026-11-24. The owner typed `/retro` after the grill, spec, plan, repo and issues for v1.0.

## Earlier ledgers

None exist, so there is nothing to grade.

## Candidates

| # | Candidate | Kind | Scope | Form | Moment | Owner's answer |
|---|---|---|---|---|---|---|
| 1 | Fix the policy hook's test for "editing code". | check | Studio 201 | add (repair of an existing check) | The hook refused 5 main-session shell commands with "the main session doesn't edit code". Four wrote only `.md` files or the memory folder. One only read file attributes through a Python heredoc. | Picked |
| 2 | Let the researcher run read-only Bash. | check | Studio 201 | add (repair of an existing check) | `agents/researcher.md` lists Bash, but the hook refused it with "researcher is read-only". The researcher could not count Homebrew casks and read 63 cask files through a summarising fetch tool. | Picked |
| 3 | A list the owner chooses gets item-by-item approval before it enters the spec. | pointer | Studio 201, `studio-201:spec` | add | The main session wrote a 55-app list into the spec. The owner answered "don't just assume and add them to the list. i need to see the catalog list and approve". | Picked |
| 4 | The issues skill views the first issue body before it opens the rest. | pointer | Studio 201, `studio-201:issues` | add | A shell loop did not split words under zsh. 15 issues were posted with empty proof sections and then rewritten. | Rejected |
| 5 | The plan template takes the project name. | check | Studio 201, `skills/plan/template.html` | add | The plan page's title and heading read "Studio 201 plan" in the Settlein repo. A mechanic fixed it in two passes. | Picked |
| 6 | Count a list by command before stating its size. | pointer | Studio 201, `studio-201:spec` | add | The main session said the proposed catalog held 55 apps when it held 56. | Picked |

## Picks

Candidates 1, 2, 3, 5 and 6. Each becomes a draft issue for `asarelcastellanos/studio-201`. The owner approves each draft before it is posted.

## Rejections

Candidate 4, kind pointer.
