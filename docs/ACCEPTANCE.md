# Gtext acceptance evidence

No private content in this file. Each entry records date, phase, fixture
command, approved scenario, observed result, and blocked reason.

## 2026-09-30, Stage 1 baseline

- Phase: preserve reliability baseline, repeatable native tests.
- Toolchain: Swift 6.4 (swiftlang-6.4.0.34.1, target arm64-apple-macosx27.0.0),
  SDK MacOSX 27.0 at /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk.
- Fixture command: `./build.sh && ./scripts/test.sh && /usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' dist/Gtext.app/Contents/Info.plist && codesign --verify --strict dist/Gtext.app`.
- Observed result: build OK with internal `Info.plist: OK`; `PASS native tests`;
  PlistBuddy printed `local.mareox.gtext` (unchanged); strict codesign verify
  passed with no output.
- Approved scenario pending: full user-confirmed relaunch of the rebuilt
  `dist/Gtext.app`, existing auth loads with no cookie reset. Not yet performed.
- Blocked reason: relaunch confirmation requires MareoX. Run the new app,
  confirm threads load without a sign-in prompt, then optionally log with
  `scripts/observe.sh paired relaunch`.
- Gates and deviations recorded 2026-09-30: native-shell implementation
  approved by MareoX with F01 waiver for shell work; sensitive stages
  (sends, OTP copy/submit, notification permission, login items, installs,
  pairing changes) remain gated. Local `.git` has no remote and no commits;
  per explicit no-git silo direction, execution proceeds without a Git
  baseline and without creating a repo or remote.

- Update 2026-09-30: MareoX opened the staged `dist/Gtext.app` (process verified live from the project dist path) and replied "its open", then "still good" when asked whether threads load with no sign-in prompt. Recorded verbatim as user-confirmed relaunch acceptance for the Stage 1 build. No observation file entry was made by the executor.

## 2026-09-30, Stage 2 shell

- Phase: settings, zoom, appearance, windows, background lifecycle, manual reload recovery.
- Fixture command: `./scripts/test.sh && ./build.sh`, then PlistBuddy bundle ID read and strict codesign verify.
- Observed result: `PASS native tests` (zoom 0.1 to 0.50, 9 to 2.00, reset to 1.00, malformed prefs to defaults, frame validation on-screen, unknown draft to warning, declined to zero reloads, in-flight to reload disabled); build OK with internal `Info.plist: OK`; PlistBuddy `local.mareox.gtext` unchanged; strict verify passed silent.
- Changed files: `Sources/PreferencesStore.swift` (new), `Sources/SettingsWindowController.swift` (new), `Sources/WindowCoordinator.swift` (new), `Sources/main.swift` (menus, coordinator wiring, warned reload, background-aware quit), `tests/native-tests.swift` (@main entry plus stage 2 assertions), `scripts/test.sh` (compiles tests plus pure support modules).
- Approved scenario pending: user runtime check of the rebuilt app (zoom 50/100/200 survives relaunch, Settings and View menus work, background close/reopen behavior, appearance and Spaces change without erasing paired state). The rebuild replaces the Stage 1 binary, so relaunch the new `dist/Gtext.app` before judging.
- Blocked reason: runtime check requires MareoX with the paired session. No sends, OTP, notifications, login items, installs, or pairing changes touched.

- Update 2026-09-30: MareoX relaunched the rebuilt app and replied "done, relaunched" with no issues reported. Recorded as Stage 2 runtime acceptance.
- Config per MareoX request: `defaults write local.mareox.gtext gtext.runInBackground -bool true` (verified read-back `1`). Red close now keeps Gtext in the Dock; only Quit terminates. No code change; same checkbox lives in Settings under General. Pending user check that close-then-Dock-click restores the window.
- Close-behavior check 2026-09-30: MareoX replied "it works". Recorded as acceptance for red-X-to-Dock plus Quit-quits.

## 2026-09-30, Stage 3 downloads and login items

- Phase: user-confirmed downloads and login-item controls (native shell only, no live permission or install performed by the executor).
- Fixture command: `./scripts/test.sh && ./build.sh`, then PlistBuddy bundle ID read and strict codesign verify.
- Observed result: `PASS native tests` (filename sanitization, collision rename to `a 2.txt`/`a 3.txt` with existing bytes preserved, nil and malformed bookmarks require save panel, login redirects never downloads, login-item error reports not enabled); build OK with internal `Info.plist: OK`; PlistBuddy `local.mareox.gtext` unchanged; strict verify passed silent. First attempt failed on bookmark `inout` flag shape in this SDK; fixed with an explicit stale flag and passed on attempt 2.
- Changed files: `Sources/DownloadCoordinator.swift` (new), `Sources/LoginItemCoordinator.swift` (new), `Sources/PreferencesStore.swift` (folder bookmark accessor), `Sources/main.swift` (download policy and creation delegates), `Sources/SettingsWindowController.swift` (Open at login row, click-only registration, approval offers System Settings), `build.sh` plus `scripts/test.sh` (ServiceManagement framework link).
- Approved scenario pending: user downloads a nonprivate fixture and confirms destination with matching bytes, cancel creates nothing, existing-file refusal preserves bytes; login item enable/disable reflects the OS after explicit install and permission. Login-item and live notification acceptance still require the separately approved stable installed path and signing identity, not ad-hoc development signing.
- Blocked reason: live scenarios require MareoX with the paired session and explicit install. No registration performed, no launch agent, no sends, OTP, or pairing changes touched.

## 2026-09-30, Stage 3 correction (evidence-bound, coordinator review)

- Scope: already-approved Stage 3 native download gaps only. No new permission asked.
- Incoming evidence: coordinator-verified findings against stored bytes (SHA256 `2feec364...c87c1` matched exactly before edits); peer bundle `_c-plans/2026-09-30-stage3-peer-review.txt` is a limited review, not a completion certificate.
- Partial work separated: earlier native PASS covered only destination helpers. Empty `downloadDidFinish` and failure bodies, unbalanced scoped access, silent custom-folder rename, and missing folder-chooser UI are now fixed, not retrospectively claimed.
- Fixed native checks: finish records the completed URL and offers Reveal in Finder only for it; failure shows an error alert with no auto-resume and silent cancel; scoped access releases exactly once on success, failure, and cancel, with duplicates and unacquired terminals releasing nothing; custom folders go through the common save panel preset to the chosen directory with native overwrite consent, exact URL saved, nil on cancel; Settings gains a working Choose folder control storing a verified bookmark, with fallback to per-download panel on failure.
- Fixture command: `./scripts/test.sh && ./build.sh`, then PlistBuddy bundle ID read and strict codesign verify. Observed: `PASS native tests`, build OK, `local.mareox.gtext` unchanged, strict verify silent. Passed on first validation attempt; two intermediate source repairs (duplicated destination block, eaten method header) were corrected before the run.
- Changed files: `Sources/DownloadCoordinator.swift` (lifecycle ledger, decision helper, common panel flow, finish and fail UI), `Sources/SettingsWindowController.swift` (enabled custom-folder checkbox plus Choose folder with bookmark storage), `tests/native-tests.swift` (decision, scope, ledger ordering tests replacing silent-rename helper tests).
- User-only gates unchanged: live fixture download with matching bytes, cancel and refusal behavior, login-item status after explicit install and permission, stable installed path and signing identity. No live downloads, overwrites, registrations, sends, OTP, or pairing changes by the executor.

## 2026-09-30, Stage 4 native notification foundation (synthetic only)

- Scope: coordinator-directed native plumbing under existing approval. No live page signals, no preview extraction, no real permission prompt by the executor.
- Changed files: `Sources/NotificationCoordinator.swift` (new, opaque IDs, one request per event, duplicates/history/outgoing/active suppressed, permission only via explicit enable), `Sources/DockCoordinator.swift` (new, badge matrix, bounce only while inactive and enabled with one bounce per event, single sound play, bounded dedupe), `tests/fixtures/page-events.html` (new, fourteen fabricated events), `Sources/main.swift` (live wiring with category registration and read-only authorization refresh, no page signal connection), `Sources/SettingsWindowController.swift` (enable toggle requests permission only on user click), `build.sh` plus `scripts/test.sh` (UserNotifications framework link).
- Fixture command: `./scripts/test.sh && ./build.sh`, then PlistBuddy bundle ID read and strict codesign verify. Observed: `PASS native tests` (duplicate to one post and bounce, ten fixture distinct to ten requests, denied and disabled to zero, active conversation quiet, empty and oversized IDs rejected, unknown and negative unread to no badge, zero to clear); build OK; `local.mareox.gtext` unchanged; strict verify silent. Attempt 1 failed on `NSBeep` missing from this SDK; system Funk sound substituted, passed on attempt 2.
- Explicitly not parity: no Google inbound delivery, no clickthrough, no OTP, no reply. Those need the stage 5 adapter addendum and live evidence.
- User-only gates unchanged: labelled local test notification only after explicit permission (not proof of inbound delivery); live download, login-item, and signing gates still pending.

## 2026-09-30, Stage 4 independent verification plus Stage 5 preparation

- Coordinator verification recorded: independent rerun of `./scripts/test.sh` printed `PASS native tests`; strict verify passed; bundle ID unchanged; stored binary untouched by verification. Accepted as native synthetic plumbing only, not inbound, permission-retention, preview, OTP, reply, or navigation acceptance.
- Preparation only, no inspection performed: re-read plan section 5 stop gate; `--inspect-page` opt-in gate implemented (`Sources/InspectionGate.swift`, wired default-off in `main.swift`) with fixture tests for flag present and absent plus OS floor 13.3; `docs/PAGE-CONTRACT.md` created as an explicitly UNVERIFIED scaffold with all ten signals unproven. No selectors, bridge code, or production features added. One launch-order repair (stranded settings plus lost authorization refresh) corrected before the green run.
- Fixture command output: `PASS native tests`, build OK, `local.mareox.gtext` unchanged, strict verify silent.
- Blocked technical capability: supervised read-only metadata inspection of the paired app needs MareoX present. Nothing further can proceed on the adapter until that observation exists and its addendum passes independent review.

## 2026-09-30, Stage 5 supervised inspection session 1

- Method: agent-driven Web Inspector with MareoX present and assisting with disclosure clicks; Safari attach considered and rejected for ego-lite with documented reasons (own engine and store, needs a second pairing, plan prescribes the inspectable path).
- Observed: gate proved (flagged binary listed under Develop, no re-pair); P1 origin and frame; app shell with stable `data-e2e-*` hooks; list container anchor `mw-main-nav[data-e2e-conversation-list]` with inner router outlet; aria-live announcer noted unproven. Evidence banked in `docs/PAGE-CONTRACT.md` entries E1 to E3. No message, contact, cookie, OTP, or HTML content recorded anywhere.
- Still unverified: row structure, identity, unread, active, history timing, compose, sent states, account and signout. Inspector session ended at MareoX request before row expansion; resumable on reattach since page structure persists.
- Runtime restore required: quit the flagged `--inspect-page` instance and relaunch normally, then confirm threads load.
