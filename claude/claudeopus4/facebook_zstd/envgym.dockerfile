# Dockerfile for zstd development environment
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and development tools
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    zlib1g-dev \
    liblz4-dev \
    liblzma-dev \
    libzstd-dev \
    gzip \
    xz-utils \
    lz4 \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/

# Build zstd
RUN make clean && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Set the default command to bash
CMD ["/bin/bash"]