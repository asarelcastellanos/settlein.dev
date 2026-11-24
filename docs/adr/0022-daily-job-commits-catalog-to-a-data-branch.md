---
status: accepted
date: 2026-11-24
---
# 0022. Daily job commits the catalog to a data branch

Accepted by default, not reviewed by the owner.

## Context and problem statement

[ADR-0015](0015-settlein-publishes-its-own-catalog-file.md) and [ADR-0020](0020-catalog-generator-in-node-under-catalog.md) say a daily job rebuilds `catalog/catalog.json`. GitHub runs a scheduled workflow only from the latest commit on the default branch, which is main ([GitHub docs, events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)). Main takes only `release/v1.0` merges, each with the owner's approval, and agents never commit to main. A job that pushes the catalog to main every day would bypass that flow.

## Considered options

* The workflow lives on main, reads the generator from main and pushes the rebuilt file to a `catalog-data` branch
* The workflow lives on main and pushes the rebuilt file to main
* The workflow lives on main and opens a pull request each day that changes the file

## Decision outcome

Chosen option: "The workflow lives on main, reads the generator from main and pushes the rebuilt file to a `catalog-data` branch", because the daily file never touches main, needs no review step and gives the site deploy (issue #8) one branch to read.

`.github/workflows/catalog.yml` runs at 05:17 UTC and on `workflow_dispatch`. It checks out main for the generator and `catalog-data` into `data/`. It runs `node catalog/generate.mjs catalog/apps.json data/catalog.json`. When `data/catalog.json` differs, it commits and pushes to `catalog-data`. When the generator exits 1, the step fails, the job fails, GitHub emails the owner and nothing is committed. The job holds `contents: write` and nothing else. It pins `actions/checkout` to `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1) and `actions/setup-node` to `949feb2413d6458794dcd2491c4babbbce0c15c1` (v7.1.0).

The job runs only after `release/v1.0` reaches main, and it needs the `catalog-data` branch to exist. `workflow_dispatch` also needs the workflow file on the default branch ([GitHub docs, manually running a workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)). Until then no run exists, so C2's run history cannot exist before the release merge.

### Consequences

* Good, because main changes only through the release flow.
* Good, because a failed run leaves the last good file on `catalog-data`.
* Good, because the branch history is one commit per day that the catalog changed.
* Bad, because `catalog/catalog.json` on main goes stale after the release merge. The site deploy and the app must read the file from `catalog-data`.
* Bad, because GitHub disables a scheduled workflow in a public repository after 60 days without repository activity ([GitHub docs, disabling a workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/disable-and-enable-workflows)). The owner must watch for a missing run.
