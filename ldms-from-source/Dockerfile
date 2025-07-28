FROM ubuntu:22.04

# Install required packages
RUN apt update && apt install -y \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    libnuma-dev \
    libssl-dev \
    python3 \
    python3-docutils \
    python3-dev \ 
    wget \
    gettext \
    pkg-config \
    flex \
    bison \
    libjansson-dev \
    && apt clean

# Set working directory
WORKDIR /root

# Clone and build LDMS
# RUN git clone https://github.com/ovis-hpc/ovis.git && \
#     cd ovis && \
#     ./autogen.sh && \
#     ./configure --enable-sos --prefix=/usr && \
#     make -j$(nproc) && \
#     make install

RUN git clone --recurse-submodules https://github.com/ovis-hpc/ovis.git && \
    cd ovis && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

# Optional: set LD_LIBRARY_PATH (if needed for runtime)
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib

# Copy your entrypoint and other config files
COPY entrypoint.sh stream_csv.sh ./
RUN chmod +x entrypoint.sh stream_csv.sh

# existing base stuff here
COPY agg.conf /root/agg.conf

# Directory where store_csv will write
RUN mkdir -p /root/storage

# Run the entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]
