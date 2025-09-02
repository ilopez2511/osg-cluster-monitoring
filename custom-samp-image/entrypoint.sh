#!/bin/bash
set -euo pipefail

cd /root

# Ensure CSV store root exists (used by agg)
mkdir -p /root/storage

ROLE="${ROLE:-samp}"
LDMSD_FLAGS="${LDMSD_FLAGS:-}"

# Default sampler port (what agg will connect to)
SAMP_PORT="${SAMP_PORT:-10001}"

if [ "$ROLE" = "agg" ]; then
  # 1) Build COMPUTE_NODES if missing: discover sampler tasks via Swarm DNS
  if [ -z "${COMPUTE_NODES:-}" ]; then
    tries=${DISCOVERY_TRIES:-30}
    delay=${DISCOVERY_DELAY:-2}
    for _ in $(seq 1 "$tries"); do
      COMPUTE_NODES="$(getent hosts tasks.samp | awk '{print $1}' | paste -sd, - || true)"
      [ -n "$COMPUTE_NODES" ] && break
      sleep "$delay"
    done
  fi

  # 2) Turn COMPUTE_NODES (comma-separated IPs/hosts) into prdcr_* lines
  COMPUTE_NODES_LINE=""
  if [ -n "${COMPUTE_NODES:-}" ]; then
    IFS=',' read -r -a nodes <<< "$COMPUTE_NODES"
    for i in "${!nodes[@]}"; do
      node="${nodes[$i]}"
      name="sampler$((i+1))"
      COMPUTE_NODES_LINE+="prdcr_add name=$name host=$node port=${SAMP_PORT} xprt=sock type=active reconnect=20000000\n"
      COMPUTE_NODES_LINE+="prdcr_start name=$name\n"
    done
  fi
  export COMPUTE_NODES_LINE

  # 3) Render final config to /root/ldmsd.conf (so your LDMSD_FLAGS -c points here)
  envsubst < /root/agg-template.conf > /root/ldmsd.conf

  # 4) Start ldmsd
  if [ -n "$LDMSD_FLAGS" ]; then
    # example: -x sock:20001 -c /root/ldmsd.conf -l /root/ldmsd.log -v DEBUG
    eval ldmsd $LDMSD_FLAGS &
  else
    ldmsd -c /root/ldmsd.conf -l /root/ldmsd.log -v DEBUG &
  fi

  # 5) Start CSV streaming helper (optional)
  if [ -x /root/stream_csv.sh ]; then
    /root/stream_csv.sh &
  fi

else
  # ROLE=samp
  # Render sampler config (if it uses env vars like ${HOSTNAME})
  envsubst < /root/samp.conf > /root/ldmsd.conf

  if [ -n "$LDMSD_FLAGS" ]; then
    # example: -x sock:10001 -c /root/ldmsd.conf -l /root/ldmsd.log -v DEBUG
    eval ldmsd $LDMSD_FLAGS &
  else
    ldmsd -x sock:${SAMP_PORT} -c /root/ldmsd.conf -l /root/ldmsd.log -v DEBUG &
  fi
fi

# Keep the container alive
tail -f /dev/null
