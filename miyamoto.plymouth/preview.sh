#!/usr/bin/env bash
set -uo pipefail

log=/tmp/miyamoto-plymouth.log
rm -f "$log"

plymouthd --no-daemon --debug --debug-file="$log" --pid-file=/tmp/miyamoto-plymouth.pid &
dpid=$!

sleep 2
plymouth --show-splash || echo "show-splash failed"
sleep 5
plymouth --quit || true
wait "$dpid" 2>/dev/null || true

echo "=== theme-load related log lines ==="
grep -iE "script|theme|image|sprite|error|warning|parse|miyamoto|font" "$log" 2>/dev/null | tail -n 80
echo "=== last lines ==="
tail -n 20 "$log" 2>/dev/null
