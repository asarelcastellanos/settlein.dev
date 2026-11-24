---
status: accepted
date: 2026-11-24
---
# 0017. No Mac App Store apps

## Context and problem statement

Apple does not let another app start a Mac App Store install. The grill left App Store apps out of the first version (Q7, Q22) and did not say whether a later version would add them. The owner then settled it for every version.

## Considered options

* Never list Mac App Store apps
* Leave them out of v1.0 and revisit later
* List them and open each App Store page for the person

## Decision outcome

Chosen option: "Never list Mac App Store apps", because the owner said "we should never have mac app store apps anyeways". The App Store already reinstalls a person's purchases from one place.

### Consequences

* Good, because every app in the catalog is one Settlein can install and remove by itself.
* Good, because the catalog format never needs an App Store entry type.
* Bad, because apps such as Xcode and Final Cut Pro can never appear, so a new Mac still needs one visit to the App Store.
