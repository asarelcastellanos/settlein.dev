---
status: accepted
date: 2026-11-25
---
# 0043. Notarization lookup failure gets its own refusal message

Accepted by default, not reviewed by the owner.

## Context and problem statement

ADR-0029 checks each staged bundle against a requirement that ends in `notarized`. For an app without a stapled ticket, such as VLC 3.0.24, the system confirms notarization with an online lookup. When the lookup fails, the check fails and SettleIn said "not signed with a valid Developer ID". The #99 runs hit this while QA had Wi-Fi off for C50 (issue #150). VLC itself passes `codesign`, `spctl` and the pipeline when online.

## Considered options

* Keep the requirement and the refusal, and split the diagnosis into two messages
* Drop `notarized` from the requirement when the lookup fails
* Keep one message

## Decision outcome

Chosen option: "Keep the requirement and the refusal, and split the diagnosis", because C22 still demands a notarized app and an unconfirmed notarization must not install.

When the full requirement fails, `Verify.signatureProblem` checks the same bundle against the Developer ID requirement without `notarized`. If that passes, it returns "SettleIn could not confirm with Apple that the app is notarized", which the run text shows as a connection problem with a retry hint. If it fails too, the old Developer ID message stays. A seal failure and an unsigned bundle keep their messages and order. The install policy does not change. This refines ADR-0029.

### Consequences

* An offline run now tells the user to check the connection.
* A non-notarized Developer ID app shows the same message as an offline run, because the system cannot tell them apart. The user retries once and gets the same refusal.
