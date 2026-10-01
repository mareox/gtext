# Gtext visual and interaction design

## Identity

Display/app/executable: Gtext. Bundle ID: `local.mareox.gtext`. Selected icon: A, midnight signal, at [PNG](../Resources/icon-v2-a.png) and [ICNS](../Resources/Gtext.icns). Dark indigo rounded tile with a filled cyan-to-blue speech bubble; the generator's historical outline comment does not describe the actual rendered fill. No Google wordmark or Texty artwork is copied.

## Current interaction

Main window contains Google's unmodified web UI. AppKit main window is 1050x760 initially; resizable/minimizable/closable. A sign-in popup uses a real child WKWebView and a 680x720 native window. Standard Copy/Paste/Select All and Quit are present. Frame restoration and background-on-close are not yet implemented.

## Planned native shell

Settings groups: General, Appearance, Notifications, Downloads, Privacy. Defaults are conservative: follow system appearance, zoom 100%, notifications off until opt-in, bounce off, OTP automatic copy off, close quits unless background mode selected. Settings requiring page integrations are disabled with an explicit unsupported reason until their adapter is verified.

Menus: Gtext > Settings and Quit; View > Zoom In/Out/Actual Size; Window > Bring to Front. Zoom matches Texty's current 50-200% range in 5-point steps. Dock menu adds New Conversation after compose navigation is verified; this opens compose but never sends.

## Feedback and failure states

Use normal macOS permission prompts only on an explicit user action. Show unavailable/login-required/phone-offline state separately. Unknown send outcome must say unknown; never show a fake success. Copying an OTP must show a discreet indication but not expose the code in diagnostics. Download failure must be visible and must not imply file completion.

## Icon in Dock

The actual bundle declares `CFBundleIconFile=Gtext` and does not use `CFBundleIconName`. Compare the source/bundle ICNS bytes before suspecting caches. Do not repeatedly kill Dock or touch session storage. Cache refresh plus LaunchServices registration resolved the prior user-reported icon problem; the screenshot itself was the original symptom, not proof of a particular cache layer.
