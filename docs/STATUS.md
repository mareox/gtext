# Gtext status and acceptance evidence

Last checked: 2026-09-30. Product owner: MareoX.

| Gate | Status | Evidence |
| --- | --- | --- |
| Build and local signing | Passed at relocated project | Swift compilation, plist and strict ad-hoc signature checks |
| Official account authentication | User-confirmed | MareoX reported successful authentication; no credentials retained |
| Cold quit/relaunch | User-confirmed | Private observer recorded paired relaunch |
| Icon A in Dock | User-confirmed | MareoX selected A and later said it looks good |
| Sign-in popup-specific callback path | Not independently observed | Current source retains child view/window; successful auth alone does not prove popup branch |
| Sleep/wake, reboot | Pending | No such events recorded |
| Fourteen-day reliability | In progress | Two paired observations: initial and relaunch; both local 2026-09-29 |
| Texty native features | Planned only | See feature matrix and new plan |

## Repository location

The complete source and documentation now live in the requested `macos-gtext` folder alongside the widgets project. Previous misplaced Gtext directories are to be trashed only after byte-identity verification. Git metadata is preserved; no remote or first commit has been created. App Support and WebKit data are not source leftovers and must not be trashed.

## Relocation caveat

The app was not running during consolidation. The app path changes, but bundle ID, binary, icon and website storage are preserved. Relocation must be noted in trial evidence. A reopened conversation at the new path requires direct user confirmation before a new paired observation is recorded. Do not reset the clock or claim the move proves continuity.

## Next action

Review the Texty plan before implementing features. Continue real paired observations during normal use; record wake/reboot only after the real event. Current documentation work does not authorize sending messages, changing Google pairing, or automatic login-item registration.
