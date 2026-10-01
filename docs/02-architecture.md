# Gtext architecture and security

## Current runtime

AppKit NSApplication runs a regular app with a main NSWindow containing WKWebView. The view uses WKWebsiteDataStore.default(), whose website data persists. createWebViewWith uses WebKit's supplied configuration for a retained child view and popup window; webViewDidClose and windowWillClose release it. Closing the final window currently terminates the app. No native notification or messaging bridge exists.

## Boundaries

Google controls sessions, pairing and message transport. Gtext controls native windowing and its local website store. Persistent cookies do not override server revocation. WKWebView is separate from the normal browser profile; do not import or export cookies. Website data stays managed by WebKit, with no invented on-disk path guarantee.

## Planned layers

Native shell: PreferencesStore, WindowCoordinator, DownloadCoordinator, LoginItemCoordinator. Inbound bridge: versioned PageSignalBridge with strict origin/frame/schema checks. Native integration: NotificationCoordinator, DockCoordinator, ConversationRouter. Sensitive operations: OTPAssistant and InlineReplyCoordinator only after independent evidence gates. The [build plan](../_c-plans/2026-09-30-texty-parity-build-plan.md) defines sequence and failure behavior.

## Message data and permissions

Do not persist message bodies or credentials in source, fixtures, settings, diagnostic files or screenshots. Future inline replies may carry user-entered text briefly in memory; future OTP features require opt-in and ephemeral handling. Notification privacy default is generic body. WKWebView web push is not assumed to work; app-native notification delivery still needs a verified incoming-message source.

## Source layout

- Sources/main.swift: current app delegate, main/popup lifecycle and menus.
- build.sh: compile, generate plist, copy icon, sign and verify bundle.
- scripts/observe.sh: validated state/event logger, not a message-event source.
- scripts/make_icon_v2.swift: source generator including design experiments; A is selected.
- Resources/Gtext.icns + icon-v2-a.png: selected artwork.
- docs/: product documentation. _c-plans/: historical and current execution artifacts.
- dist/: built local app; ignored by Git.

## Version compatibility

The build uses the current host SDK without an explicit deployment-target flag. Info.plist declares macOS 13, but this has not been verified on that OS. Future ServiceManagement, UserNotifications, WebKit download and inspectability APIs require availability checks and testing. No exact minimum-OS promise is made from plist alone.
