# 04 — Pairing trial protocol

## Purpose

Prove or disprove that the dedicated app holds pairing for 14 consecutive calendar days. A pass authorizes planning Texty parity features. A fail stops the project and reports the measured cause.

## Observation log

Location: `~/Library/Application Support/Gtext/observations.tsv`, directory mode 700, file mode 600. Each line is `UTC-timestamp TAB state TAB trigger`. Nothing else is ever written there: no cookies, messages, numbers, URLs, or page content.

Record with:

```sh
./scripts/observe.sh <state> <trigger>
```

## States

| State | Meaning |
|---|---|
| `paired` | Existing threads are visible. |
| `signed-out` | Login or pairing screen is visible. Trial failed, stop and report. |
| `connection-error` | Still paired but phone or network unreachable. Does not count as a paired observation. |
| `login-blocked` | Google refused sign-in in the embedded view. Route failed, stop and report. |

If ambiguous between signed-out and connection trouble, log `connection-error` and keep a separate private note without identifiers.

## Triggers

`initial` (first pairing), `daily` (routine check), `relaunch` (after cold app quit and relaunch), `wake` (after sleep and wake), `reboot` (after OS restart). Confirm the wake and reboot actually happened; the label alone is not the proof.

## Schedule

14 consecutive calendar days with visually confirmed `paired` observations on at least 10 distinct local (America/Los_Angeles) dates, including one `relaunch`, one `wake`, and one `reboot` event each on a paired row. Missed days extend the window until one contiguous 14-day window contains the checks. Google's few-weeks inactivity expiry is outside this window and remains untested.

## Fail-once rule

A single `signed-out` or `login-blocked` anywhere in this first-pair trial is a definitive fail, even if a later window looks clean. Never re-pair, erase the log, or silently restart the trial to manufacture a pass.

## Acceptance checker

```sh
cd /path/to/gtext
python3 - <<'PY'
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo
path = Path.home() / "Library/Application Support/Gtext/observations.tsv"
rows = [line.split("\t") for line in path.read_text().splitlines()] if path.exists() else []
valid = all(len(row) == 3 and row[1] in {"paired", "signed-out", "connection-error", "login-blocked"} and row[2] in {"initial", "daily", "relaunch", "wake", "reboot"} for row in rows)
try:
    records = [(datetime.strptime(row[0], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc).astimezone(ZoneInfo("America/Los_Angeles")).date(), row[1], row[2]) for row in rows] if valid else []
except ValueError:
    valid = False
    records = []
required = {"relaunch", "wake", "reboot"}
days = sorted({day for day, _, _ in records})
paired_days = {day for day, state, _ in records if state == "paired"}
initial_logged = any(state == "paired" and event == "initial" for _, state, event in records)
today = datetime.now(ZoneInfo("America/Los_Angeles")).date()
windows = [(start, [r for r in records if start <= r[0] <= start + timedelta(days=13)]) for start in days]
covered = any(today >= start + timedelta(days=14) and len({day for day, state, _ in window if state == "paired"}) >= 10 and required.issubset({event for _, state, event in window if state == "paired"}) for start, window in windows)
passed = valid and initial_logged and covered and not {"signed-out", "login-blocked"}.intersection(state for _, state, _ in records)
print("PASS" if passed else "FAIL", "paired_dates=", len(paired_days), "signouts=", sum(state == "signed-out" for _, state, _ in records), "required_events=", sorted(required.intersection({event for _, state, event in records if state == "paired"})))
raise SystemExit(0 if passed else 1)
PY
```

Expect `PASS` with 10 or more paired Los Angeles dates inside one completed 14-day window, all three required triggers on paired rows, and zero sign-outs or login blocks anywhere in the trial. It prints only aggregate counts and labels.

## Trial history

- `2026-09-30T00:24:23Z` — `paired initial`. MareoX authenticated successfully in Gtext. Window 1 of 14 days opened.

## Consolidation note, 2026-09-30

The source/app moved to the requested project folder while Gtext was not running. Its bundle ID and private observation data are unchanged. The path move is a documented intervention, not a paired observation or fresh trial. Initial and relaunch are user-reported; wake/reboot and the complete window remain pending.
