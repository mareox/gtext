# Gtext troubleshooting

## Login or pairing required

A login/pairing screen is a different state from an offline phone. Log signed-out only after observing it. Do not erase WebKit storage, spoof the browser, import cookies, or silently re-pair; preserve evidence and classify the failure.

## Phone/network unavailable

If still paired but connectivity fails, log connection-error. After service recovers, verify a real conversation before logging paired. Offline observations do not count toward ten paired dates.

## Icon is wrong in Dock

Compare Resources/Gtext.icns and dist/Gtext.app/Contents/Resources/Gtext.icns; inspect CFBundleIconFile. The current working plist has no CFBundleIconName key. Confirm the actual running app path before rebuilding a different copy. If the resource is correct and app was rebuilt, fully quit and reopen first. If the app shows the new icon but the Dock still shows the old one, restart Dock once with `killall Dock` and reopen the verified bundle. This resolved the Cobalt icon on 2026-10-27, confirmed by MareoX. Do not clear auth data; repeated Dock restarts are not diagnosis.

## Build fails

Check `xcode-select -p` and `swift --version`. Full Xcode is not required for the current single-source app. No packages need installing. Inspect the exact compiler error before editing.

## Relocation

This folder now owns the app. The previous two Gtext directories are redundant and recoverably trashed, not current owners. If Gtext's old Dock shortcut no longer resolves, open dist/Gtext.app from this folder and pin that running app. Reopening does not authorize re-pairing if login is lost.

## Observation evidence

Invalid TSV records fail the checker. Never edit a failed event away or label a synthetic fixture as a real observation. The [trial protocol](04-pairing-trial.md) is unchanged except for the current project path and Gtext identity.
