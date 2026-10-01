# Gtext overview

Gtext is a native macOS shell around Google Messages for web, not an official Google client. The initial goal is fewer unexpected reauthentication prompts. Later phases aim to match Texty's native conveniences. [PRD](../PRD.md) owns requirements; [feature matrix](FEATURE-MATRIX.md) separates implemented, inherited and planned behavior; [status](STATUS.md) owns current evidence.

## Current build

One AppKit application and persistent WKWebView. No message backend, subscription, analytics, browser cookie importer, or copied Texty script. Official sign-in and relaunch succeeded according to MareoX; long-term retention is still unproved.

## Texty reference

[Texty product page](https://www.tunabellysoftware.com/texty/) and [release notes](https://www.tunabellysoftware.com/texty/releasenotes/) define the public parity target. Installed Texty 1.3.12 preferences corroborate settings, not runtime success. Google provides the actual conversation/SMS/MMS/RCS behavior.

## File ownership

This folder is the single source/app/docs working project. The homelab wiki retains durable research and milestone summaries; it is not another app source copy. Historical approved plans are retained unchanged and superseded by the dated relocation/parity plan for current paths.
