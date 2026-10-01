# Texty feature parity matrix

Updated 2026-09-30. Sources: [current product page](https://www.tunabellysoftware.com/texty/), [release notes](https://www.tunabellysoftware.com/texty/releasenotes/), installed Texty 1.3.12 preference defaults/localizations. Vendor claims and defaults establish the target, not verified Gtext behavior. Feature IDs are shared by the PRD and implementation plan.

| ID | Feature | Gtext now | Required acceptance | Planned release |
| --- | --- | --- | --- | --- |
| F01 | Official Google sign-in, durable pairing | Current proof | A 14-day paired window; Google controls expiry | R0 |
| F02 | SMS/MMS/RCS, receipts, typing, existing threads | Inherited web UI, not parity-tested | Exercise supported conversations on Google web | R0/service tests |
| F03 | Media, attachments, drag/drop, Google Photos | Inherited/unverified | User-approved fixture upload and download; test popup picker | R1/service tests |
| F04 | Emoji, reactions, GIFs/stickers, spellcheck | Inherited/unverified | Test currently supported Google/macOS controls | R1/service tests |
| F05 | Zoom 50-200%, 5% increments | Planned | Clamp/reset and persist pageZoom | R1 |
| F06 | Native notifications, each new message separate | Planned, adapter-gated | One fresh inbound message => one generic notification; no replay spam | R2 |
| F07 | Notification clickthrough and inline reply | Planned, evidence-gated | Exact conversation binding; submit once; confirmed/failed/unknown, no automatic retry | R2 clickthrough/R3 reply |
| F08 | OTP manual copy and optional automatic copy | Planned, sensitive-data gate | Fresh unambiguous code only; automatic off until opt-in, no logging/submission | R3 |
| F09 | Unread Dock badge | Planned, adapter-gated | Trusted unread count; unknown => omit, not fabricated zero | R2 |
| F10 | Notification sounds and Dock bounce preferences | Planned | System/named user sound, none by default until enabled; one event, one alert | R2 |
| F11 | New Conversation from Dock | Planned, navigation-gated | Open Google compose only, no send | R2 |
| F12 | Custom download folder and original filenames | Planned | User destination; cancel no file; no silent overwrite | R1 |
| F13 | Scrollbar style (Google/default or system) | Planned, CSS compatibility-gated | Disable custom style when unverified; no global browser policy | R1/R2 styling |
| F14 | Window/Spaces behavior and frame persistence | Planned | Visible restored bounds; active-space vs retain-space; no offscreen windows | R1 |
| F15 | Light/dark/system appearance | Planned | Native chrome follows preference; Google appearance tested separately | R1 |
| F16 | Launch at login, background operation | Planned | Explicit opt-in; close hides only in background mode; Quit exits; permission denied handled | R1 |
| F17 | Recovery after sleep, connectivity and WebKit crash | Proof checks current; recovery planned | Never erase pairing, blindly reload unsent drafts, or falsely classify phone offline as signout | R1/R2 |
| F18 | Download complete/failed notice and reveal in Finder | Planned | Only confirmed finish yields completed; file permission/cancel failure visible | R1 |
| F19 | Settings, native Edit/context menu and shortcuts | Basic Edit current; Settings planned | Keyboard-accessible settings and state; copy/paste/current default spellcheck tested | R1 |
| F20 | Google Fi beta | Not promised | Keep as compatibility investigation; Texty historical beta is not current Gtext proof | Gated compatibility |

## Free and Pro

Current Texty Free: read/send, existing phone conversations, incoming notifications, zoom. Pro: notification replies, manual/automatic OTP copy, unread badge, notification sounds/Dock behavior, Dock compose, download/scrollbar/window preferences. Gtext intends the useful features without a subscription tier; neither Texty licensing nor App Store subscription handling is copied.

## What parity does not mean

The Google web frontend is not being reimplemented. Screenshots, selectors, and message data are not copied from Texty. F06-F11 depend on live integration evidence; F08/F07 add explicit consent and acknowledged-action constraints. Entire-project plans remain gated on the original reliability proof and a new implementation approval.
