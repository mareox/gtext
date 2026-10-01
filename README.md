# Gtext

Unofficial native macOS shell for Google Messages. MIT licensed. No third-party dependencies: Swift with system AppKit, WebKit, ServiceManagement, and UserNotifications only.

## Install from source

Requires macOS with Xcode Command Line Tools (Swift toolchain).

```sh
git clone https://github.com/mareox/gtext.git
cd gtext
./build.sh
open dist/Gtext.app
```

The build produces a universal (Apple Silicon plus Intel) ad-hoc signed app. Because it is compiled on your machine, macOS runs it without Gatekeeper objections. Optionally drag `dist/Gtext.app` into `/Applications`. A normal `Quit` terminates the app; enabling background mode in Settings keeps it in the Dock when the window closes.

Built and tested on macOS 27 (Apple Silicon). Older releases are untested despite any minimum-version string in the plist. Release archives: `GTEXT_RELEASE_ZIP=1 ./build.sh` writes a versioned zip plus SHA256 checksum into `dist/`.

## Start here

- [Product requirements](PRD.md)
- [Architecture and security](docs/02-architecture.md)
- [Build, run, and icon assets](docs/03-build-and-run.md)
- [Pairing reliability trial](docs/04-pairing-trial.md)
- [Decisions](docs/05-decisions.md)
- [Troubleshooting](docs/06-troubleshooting.md)
- [Current status and evidence](docs/STATUS.md)
- [Visual and interaction design](docs/DESIGN.md)
- [Texty feature matrix](docs/FEATURE-MATRIX.md)
- [Page contract and adapter evidence](docs/PAGE-CONTRACT.md)
- [Acceptance log](docs/ACCEPTANCE.md)

## Status

Initial authentication and cold relaunch were confirmed by MareoX. Icon A was confirmed in the Dock. The 14-day trial remains incomplete: recorded observations are initial + relaunch, not sleep/wake/reboot or ten distinct dates. See [status](docs/STATUS.md).

## Privacy

No account credentials, Google cookies, message histories, real conversations, or OTPs belong in this project. The private observation file remains at `~/Library/Application Support/Gtext/observations.tsv`. Pair Google Messages yourself in the app; the project never sees your session.
