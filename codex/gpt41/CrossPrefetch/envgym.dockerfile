FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /CrossPrefetch

# System basics
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libncurses-dev \
    software-properties-common \
    python3-software-properties \
    unzip \
    python3-setuptools \
    python3-dev \
    libboost-dev \
    python3-pip \
    libnuma-dev \
    numactl \
    libgflags-dev \
    libsnappy-dev \
    zlib1g-dev \
    libbz2-dev \
    liblz4-dev \
    libzstd-dev \
    mpich \
    && rm -rf /var/lib/apt/lists/*

# Python pip and zplot
RUN pip3 install --no-cache-dir zplot

# Copy repo
COPY . /CrossPrefetch

# Set env vars as setvars.sh
ENV NVMBASE=/CrossPrefetch \
    BASE=/CrossPrefetch \
    OS_RELEASE_NAME=focal \
    PARA="-j$(nproc)" \
    VER="5.14.0" \
    KERN_SRC=/CrossPrefetch/linux-5.14.0 \
    SHELL=/bin/bash

# Default entry: bash CLI at repo root
ENTRYPOINT ["/bin/bash"]
