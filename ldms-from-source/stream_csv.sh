#!/bin/bash
set -euo pipefail

WATCH_DIR="/root/storage"
HOST="${RECEIVER_HOST:-receiver}"
PORT="${RECEIVER_PORT:-9999}"

# requires netcat-openbsd (we install this in the agg image)
command -v nc >/dev/null 2>&1 || { echo "nc not found"; exit 1; }

mkdir -p "$WATCH_DIR"

declare -A tailed

tail_and_send() {
  local filepath="$1"
  local relpath="${filepath#$WATCH_DIR/}"
  # Send every new line as it appears (one connection per line)
  tail -n0 -F "$filepath" | while IFS= read -r line; do
    {
      echo "FILE: $relpath"
      echo "$line"
    } | nc -N "$HOST" "$PORT" || true
  done
}

while true; do
  while IFS= read -r -d '' f; do
    if [[ -z "${tailed[$f]:-}" ]]; then
      tailed[$f]=1
      tail_and_send "$f" &
    fi
  done < <(find "$WATCH_DIR" -type f -name "*.csv" -print0)
  sleep 5
done
