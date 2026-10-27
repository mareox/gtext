# Gtext decisions

| Code | Decision | Rationale and authority |
| --- | --- | --- |
| D1 | Reliability proof before native features | MareoX chose proof-first; baseline 14-day gate is still open. |
| D2 | AppKit/WKWebView with default persistent store | Smallest existing implementation; official Google login, no extra runtime. |
| D3 | Real child WKWebView for popup sign-in | Preserve opener/configuration; Opus review accepted this correction. |
| D4 | Name Gtext, ID local.mareox.gtext | User approved before initial pairing; keep stable. |
| D5 | Icon v3 B, Cobalt | MareoX selected B on 2026-10-27, replacing the previously confirmed midnight-signal A. Original G-shaped speech bubble; Dock appearance needs verification after deployment. |
| D6 | Fail-once first-pair trial | No hidden re-pair/reset to manufacture a reliability pass. |
| D7 | Single project in the user-requested macos-gtext folder | Previous relative destination was resolved incorrectly. Source and Git metadata copied byte-identically; redundant Gtext directories trashed after validation. |
| D8 | Plan Texty parity, do not implement it yet | User requested a plan. Native integrations use original Gtext code and system frameworks, not Texty scripts/artwork. |
| D9 | Gate page-dependent integrations | Google DOM and sent acknowledgements unverified. Do not invent selectors or infer confirmed sends from submission. |

Previous Opus 5.5 review covered the reliability plan, not all future parity work. Auth and relaunch are user-reported; success of a popup-specific branch is not independently proven. [New plan](../_c-plans/2026-09-30-texty-parity-build-plan.md) carries its own review state.
