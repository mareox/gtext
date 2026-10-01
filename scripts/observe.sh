#!/bin/bash
set -euo pipefail
case "${1:-}" in
  paired|signed-out|connection-error|login-blocked) state="$1" ;;
  *) printf 'Usage: %s STATE initial|daily|relaunch|wake|reboot\n' "$0" >&2; exit 2 ;;
esac
case "${2:-}" in
  initial|daily|relaunch|wake|reboot) event="$2" ;;
  *) printf 'Usage: %s STATE initial|daily|relaunch|wake|reboot\n' "$0" >&2; exit 2 ;;
esac
umask 077
dir="$HOME/Library/Application Support/Gtext"
file="$dir/observations.tsv"
mkdir -p "$dir"
chmod 700 "$dir"
if [ -L "$file" ] || { [ -e "$file" ] && [ ! -f "$file" ]; }; then
  printf 'Unsafe observation target\n' >&2
  exit 1
fi
printf '%s\t%s\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$state" "$event" >> "$file"
chmod 600 "$file"
printf 'Recorded %s after %s\n' "$state" "$event"
