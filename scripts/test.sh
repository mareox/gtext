#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -t gtext-native-tests)"
trap 'rm -f "$tmp"' EXIT
xcrun --sdk macosx swiftc -O -framework AppKit -framework WebKit -framework ServiceManagement -framework UserNotifications tests/native-tests.swift Sources/PreferencesStore.swift Sources/WindowCoordinator.swift Sources/DownloadCoordinator.swift Sources/LoginItemCoordinator.swift Sources/NotificationCoordinator.swift Sources/DockCoordinator.swift Sources/InspectionGate.swift -o "$tmp"
"$tmp"
