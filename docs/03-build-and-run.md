# Build, run, and artwork

Run these commands from this project folder, not from the old Gtext or widgets directories.

```sh
./build.sh
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' dist/Gtext.app/Contents/Info.plist
open dist/Gtext.app
```

Expected: plist OK, strict signature verification succeeds, bundle ID exactly `local.mareox.gtext`. It is ad-hoc signed, not notarized. Building alone does not prove login, attachment handling, notifications or session retention.

## Selected artwork

[Icon A](../Resources/icon-v2-a.png) is the selected master. The original generator uses logical 1024 units; on this Retina host its PNG is 2048x2048. Do not copy it unchanged into a slot named 512@2x and assume that is 1024 pixels. Explicitly resize to each ICNS representation.

The current bundle consumes the checked-in [Gtext.icns](../Resources/Gtext.icns); normal builds do not regenerate it. To regenerate use `swift scripts/make_icon_v2.swift`, then resize A into a temporary iconset: icon_16x16=16, 16@2x=32, 32=32, 32@2x=64, 128=128, 128@2x=256, 256=256, 256@2x=512, 512=512, 512@2x=1024; compile with `iconutil -c icns <iconset> -o Resources/Gtext.icns`. B/C are experiments, not shipped artwork; trash generated experiments after selecting A.

## Private trial logger

```sh
./scripts/observe.sh paired daily
./scripts/observe.sh paired relaunch
./scripts/observe.sh paired wake
./scripts/observe.sh paired reboot
```

Only run each command after observing that actual event. Private file: `~/Library/Application Support/Gtext/observations.tsv`; never copy it or WebKit session files into the project.
