# # base image docs: https://github.com/ovis-hpc/ldms-containers
# # FROM ovishpc/ldms-agg
# FROM ovishpc/ldms-base

# # install tools
# # RUN apt update && apt install -y gettext
# # RUN yum install -y gettext && yum clean all
# RUN command -v dnf && dnf install -y gettext --setopt=skip_if_unavailable=true || true



# # create the dir where csv fils will be saved
# RUN mkdir -p /root/storage

# # copy necessary files
# # dropping into /root to keep it simple
# COPY ./* /root/

# # entrypiont is set in docker-stack.yaml. that's more readable.
# ENTRYPOINT []

# Use LDMS aggregator image (has zap_sock.so + store_csv)
FROM ovishpc/ldms-agg

# Optional: install gettext for envsubst if needed in your entrypoint
RUN dnf install -y gettext --setopt=skip_if_unavailable=true || true

# Create required directory
RUN mkdir -p /root/storage

# Copy your scripts/configs into image
COPY ./* /root/

# Entrypoint is specified in stack YAML, leave empty here
ENTRYPOINT []

