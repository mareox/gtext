# Gtext Product Requirements Document

Version: 1.0. Updated: 2026-09-30. Product owner: MareoX. Planning scope: the Google Messages Mac app and feature parity with Texty 1.3.12. This document separates current capabilities from future requirements; it does not authorize building the future features.

## Product problem

Google Messages for web repeatedly loses authentication in MareoX's browser workflow. A dedicated Mac app should keep its own persistent website storage, use the normal Google pairing flow, and expose useful macOS integrations without a separate message backend. Google can still revoke sessions, and phone/network availability is independent of whether pairing is valid.

## Intended user and outcome

A Mac user with an Android phone using Google Messages. Open Gtext, complete official Google account + phone pairing, and return to conversations across app restarts and normal Mac use. After the reliability gate, add Texty's useful shell and notification features with privacy-preserving defaults, without a subscription layer, analytics, or copied proprietary code.

## Releases

- **R0, current proof:** one persistent WKWebView, retained sign-in popup windows, basic Edit menu, Gtext icon, human observation logging. Auth and relaunch are user-confirmed. Reliability is not yet proven.
- **R1, native shell:** zoom, settings, appearance, window/Spaces behavior, downloads, background lifecycle, login-item controls. Does not require message extraction.
- **R2, inbound integration:** trustworthy unread/new-message events, native notifications, badge, sounds, bounce, conversation clickthrough, Dock compose. Requires a verified page adapter and synthetic failure tests.
- **R3, sensitive actions:** inline notification replies and manual/automatic OTP copy. Requires additional evidence for exact conversation binding, acknowledged send outcomes, and consent. Disabled until proven.

## Functional requirements

Use stable F codes in the [feature matrix](docs/FEATURE-MATRIX.md). F01 official pairing/session retention is the first gate. F02-F04 inherit Google web capabilities (SMS/MMS/RCS, attachments, reactions/receipts/pickers); availability must be verified with the real service, not inferred from the wrapper. F05-F20 add the native features named in the matrix. Every planned feature has native/synthetic acceptance and service-level acceptance in the execution plan.

## Acceptance and safety requirements

- A complete 14-local-calendar-day window with at least ten distinct visibly paired dates and paired relaunch, wake, reboot events. A signed-out or login-blocked observation anywhere in the first-pair trial fails it; do not erase or silently restart the trial.
- Native notifications are opt-in; denied permission produces no repeated prompts. One fresh incoming message produces one notification; replay, reconnect history, outgoing messages, and visible active-conversation events do not produce duplicates.
- Unknown unread state is displayed as unknown/no badge, not fabricated zero. No message body appears in notifications by default.
- Reply actions never infer sent status from a button click. Submit exactly once on explicit user action; ambiguous completion is shown as unknown and never auto-retried. Real external-send tests require the user to approve a recipient and exact test text.
- Automatic OTP clipboard overwrite is opt-in, off by default, and never submits a code. Only a fresh eligible one-time code event may copy; multiple/stale/unsupported candidates do nothing. OTP values never enter logs, screenshots, repo fixtures, or persistent app settings.
- Download destinations require user choice. Cancel means no file written; existing files are never overwritten silently.
- Stable bundle ID and persistent WebKit store. No UA spoofing, cookie import, unofficial protocol, server, or analytics is introduced by this plan.

## UX and design

Retain Google's conversation UI in a native macOS window, not a rewritten message frontend. Follow system/light/dark appearance for native chrome and test the web view response; do not promise CSS changes until their compatibility is proven. Use standard native menus and a compact grouped Settings window. Icon A is the selected visual identity. See [design](docs/DESIGN.md).

## Platform and distribution

Swift/AppKit/WebKit, no package dependencies. SDK and compiler are those installed on the development Mac. Ad-hoc signing supports local development; it is not notarization, an App Store release, or a verified minimum-OS build. Launch-at-login requires a stable installed app location before production acceptance; relocation is not implemented as an automatic install.

## Measurements

Track reauthentication frequency, paired distinct dates, true vs duplicate inbound notification events, unknown reply outcomes, and explicit permission states. Keep only non-sensitive aggregate evidence in docs. Do not claim better reliability than Texty from two successful observations.

## Authorization and current gaps

Documentation, source consolidation, trashing redundant Gtext directories, and planning Texty feature parity were requested on 2026-09-30. Only the original proof app has implementation authorization. Phase-specific external tests and account/security permission prompts remain user-controlled. No current authenticated Google DOM selector, new-message contract, unread source, or confirmed-send signal has been verified for R2/R3. Those are explicit evidence gates, not guessed implementation details.
