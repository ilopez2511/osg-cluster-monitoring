#!/bin/bash

WATCH_DIR="/root/storage"
HOST="receiver"  # Docker Swarm DNS will resolve this
PORT=9999

tail_and_send() {
    local filepath="$1"
    local relpath="${filepath#$WATCH_DIR/}"

    tail -n0 -F "$filepath" | while read line; do
        {
            echo "FILE: $relpath"
            echo "$line"
        } | nc -q 0 "$HOST" "$PORT"
    done
}

for file in $(find "$WATCH_DIR" -name "*.csv"); do
    tail_and_send "$file" &
done

wait
