# # using ovishpc/ldms-agg for both, since it has both sampling and 
# # aggregation tools.
# # base image docs: https://github.com/ovis-hpc/ldms-containers
# FROM ovishpc/ldms-agg

# # install tools
# RUN apt update && apt install -y gettext

# COPY samp.conf /root/samp.conf
# COPY entrypoint.sh /root/entrypoint.sh
# RUN chmod +x /root/entrypoint.sh

# # copy necessary files
# # dropping into /root to keep it simple
# # COPY ./* /root/

# # entrypiont is set in docker-stack.yaml. that's more readable.
# ENTRYPOINT []

# using ovishpc/ldms-agg for both, since it has both sampling and aggregation tools.
# base image docs: https://github.com/ovis-hpc/ldms-containers
FROM ovishpc/ldms-agg

# envsubst for rendering samp.conf
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gettext-base && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

# configs + unified entrypoint
COPY samp.conf /root/samp.conf
COPY entrypoint.sh /root/entrypoint.sh

RUN sed -i 's/\r$//' /root/entrypoint.sh /root/samp.conf && \
    chmod +x /root/entrypoint.sh

# (optional) expose sampler listen port for clarity; not required in Swarm
EXPOSE 10001

# Use the unified entrypoint (ROLE is set by the stack)
ENTRYPOINT ["/root/entrypoint.sh"]
