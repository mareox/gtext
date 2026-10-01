#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
version="${GTEXT_VERSION:-0.1.0}"
app="$PWD/dist/Gtext.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
tmp="$(mktemp -d -t gtext-universal)"
trap 'rm -rf "$tmp"' EXIT
frameworks="-framework AppKit -framework WebKit -framework ServiceManagement -framework UserNotifications"
# shellcheck disable=SC2086
xcrun --sdk macosx swiftc -O $frameworks -target arm64-apple-macosx26.0 Sources/*.swift -o "$tmp/Gtext-arm64"
# shellcheck disable=SC2086
xcrun --sdk macosx swiftc -O $frameworks -target x86_64-apple-macosx26.0 Sources/*.swift -o "$tmp/Gtext-x86_64"
lipo -create "$tmp/Gtext-arm64" "$tmp/Gtext-x86_64" -output "$app/Contents/MacOS/Gtext"
cp Resources/Gtext.icns "$app/Contents/Resources/Gtext.icns"
cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Gtext</string>
<key>CFBundleDisplayName</key><string>Gtext</string>
<key>CFBundleExecutable</key><string>Gtext</string>
<key>CFBundleIdentifier</key><string>local.mareox.gtext</string>
<key>CFBundleIconFile</key><string>Gtext</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>${version}</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>26.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign "${GTEXT_SIGN_IDENTITY:--}" "$app"
plutil -lint "$app/Contents/Info.plist"
codesign --verify --strict "$app"
if [ "${GTEXT_RELEASE_ZIP:-0}" = "1" ]; then
  (cd dist && zip -qr "Gtext-${version}-macos.zip" Gtext.app && shasum -a 256 "Gtext-${version}-macos.zip" > "Gtext-${version}-macos.zip.sha256")
  printf 'Release archive dist/Gtext-%s-macos.zip\n' "$version"
fi
printf 'Built %s\n' "$app"
