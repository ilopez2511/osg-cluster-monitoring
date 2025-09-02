#!/bin/bash

# cd /root

# envsubst < samp-template.conf > samp.conf

# # start ldmsd - keeping it here so docker-stack.yaml is clean
# exec ldmsd.sh ${LDMSD_FLAGS}

set -e
cd /root

# Determine which template to use based on $ROLE
if [ "$ROLE" = "agg" ]; then
    TEMPLATE_FILE="agg-template.conf"
else
    TEMPLATE_FILE="samp.conf"
fi

echo "Generating config from $TEMPLATE_FILE"
envsubst < $TEMPLATE_FILE > ldmsd.conf

# Start ldmsd with the generated config
exec ldmsd.sh ${LDMSD_FLAGS}
