# Gtext page contract (Google Messages web adapter)

Status: PARTIAL 2026-09-30. Supervised metadata-only inspection (agent-driven
Web Inspector with MareoX present) observed the app shell and conversation
list container anchors below. Row-level structure, timing, compose, and
account signals remain UNVERIFIED. Nothing below authorizes production
adapter code. Independent review of a verified addendum is still required
before stages 6 to 8, and dependent features stay off.
- Supervised, read-only, metadata-only inspection of the paired Gtext app.
- Structural roles and attributes plus timing and source of new-message,
  unread, history/reconnect, and sent/failed states only.
- Never capture page HTML, message text, contact details, cookies, OTPs,
  or credentials in the repo. Synthetic fixtures carry fabricated data only.
- Diagnostic inspection builds set `WKWebView.isInspectable` only on
  macOS 13.3 or later when `--inspect-page` is passed. Release default off.
- No external sends during inspection.

## Required observations (P1 observed, P2 partial, rest UNVERIFIED)

| # | Signal | Required evidence | State |
| --- | --- | --- | --- |
| P1 | Exact verified origin and frame | protocol, host, port, main-frame proof | OBSERVED 2026-09-30: inspector target `messages.google.com`, main frame; only subframe is an `accounts.google.com` cookie bridge |
| P2 | New-message event source and selector | structural role/attribute, timing | PARTIAL: list container anchor observed (`mw-main-nav[data-e2e-conversation-list].main-nav` with inner `router-outlet`); row source, identity, and timing UNVERIFIED |
| P3 | Unique event identity | eventID source and uniqueness proof | UNVERIFIED |
| P4 | Unread definition | mapping to Google visible state | UNVERIFIED |
| P5 | Active-conversation definition | visible-thread mapping | UNVERIFIED |
| P6 | History and reconnect behavior | replay produces zero inbound | UNVERIFIED |
| P7 | Compose and navigation binding | verified compose-open mapping | UNVERIFIED |
| P8 | Sent, pending, failure, wrong-thread states | acknowledgement signals | UNVERIFIED |
| P9 | Account and signout state | independently observable confirmation | UNVERIFIED |
| P10 | Epoch and session generation | opaque token, changes on account change | UNVERIFIED as a page signal by design; epoch is native-derived, no page source expected |

Unsupported or unverified signals keep their dependent features off.
Guessed selectors, copied proprietary scripts, and unofficial protocol
code are not permitted as substitutes.

## Native wire schema (fixed after evidence, not yet evidenced)

`{version:1,type:"snapshot"|"incoming"|"unsupported",epoch:String,eventID?:String,conversationToken?:String,unreadCount?:Int}`.
Handler `gtextEvents` in a dedicated content world. Reject unknown keys,
versions, types, invalid counts, oversized strings, message-body data,
and payloads over 4096 bytes. Incoming requires both IDs. Unsupported or
unverified account and signout state disables notification routing, OTP,
and reply features.

## Evidence log

- 2026-09-30 E1: supervised attach proved the inspect gate. Binary carried `--inspect-page`; launch with the flag listed the Gtext page under Safari Develop with target `messages.google.com`, main frame. No re-pair requested by the app. No private content recorded.
- 2026-09-30 E2: app shell structure observed metadata-only. `<mw-app ng-version="0.0.0-PLACEHOLDER">` hosts `router-outlet`, `mw-bootstrap`, `div[data-e2e-bootstrap-main].main-stack`, `mw-gui-container` with branded header, nav drawer, and `main.content-container`. Stable hooks: `data-e2e-bootstrap-main`, `data-e2e-branded-header-menu-button`, `data-e2e-main-container`, `data-e2e-conversation-list`, `data-e2e-default-main-landing`. Angular `_ngcontent` and `ng-star-inserted` markers noted as version-fragile, not anchors.
- 2026-09-30 E3: list container anchor observed. `mw-main-nav[data-e2e-conversation-list].main-nav` contains an inner `router-outlet`; beside it sits `mw-main-landing[data-e2e-default-main-landing].main-landing.has-conversations`. Page carries its own dark theme via body classes. `cdk-live-announcer-0` (`aria-live="polite"`) noted as an unproven new-message candidate. Row-level structure, identity, unread, active, timing, compose, and account signals not yet observed.
