#!/bin/bash
set -e
cd /root

# Convert COMPUTE_NODES list into prdcr_add/prdcr_start lines
COMPUTE_NODES_LINE=""
IFS=',' read -r -a nodes <<< "$COMPUTE_NODES"
for i in "${!nodes[@]}"; do
  node="${nodes[$i]}"
  sampler_name="sampler$((i+1))"
  COMPUTE_NODES_LINE+="prdcr_add name=$sampler_name host=$node port=10001 xprt=sock type=active reconnect=20000000\n"
  COMPUTE_NODES_LINE+="prdcr_start name=$sampler_name\n"
done

# Export the generated block so envsubst can use it
export COMPUTE_NODES_LINE

# Replace variables in the template
envsubst < agg-template.conf > agg.conf

# Start LDMSD
ldmsd -c /root/agg.conf -l /root/ldmsd.log -v DEBUG &

# Start CSV streamer
bash /root/stream_csv.sh &

# Keep container alive
tail -f /dev/null
