#!/bin/bash
set -e

echo "[INFO] Starting nv-hostengine..."
nv-hostengine -b 0.0.0.0 &     # allow DCGM client connections (future LDMS integration)
sleep 2

FIELDS="100,101,150,200,203,204,230"
echo "[INFO] Collecting DCGM metrics..."
OUTFILE="/root/dcgm_metrics_$(date +%Y%m%d_%H%M%S).csv"

# Header
echo "EntityID,SMCLK,MMCLK,TMPTR,PowerUsage,PowerLimit,MemoryUtil" > "$OUTFILE"

# Append metrics
dcgmi dmon -e $FIELDS -d 1 -c 10 | \
awk '/^GPU/ {gsub(/[[:space:]]+/, ","); print}' >> "$OUTFILE"

echo "[INFO] Metrics saved to $OUTFILE"
echo "[INFO] --- BEGIN FILE CONTENT ---"
cat "$OUTFILE"
echo "[INFO] --- END FILE CONTENT ---"
pkill nv-hostengine
echo "[INFO] nv-hostengine stopped."