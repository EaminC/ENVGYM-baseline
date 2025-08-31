FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ninja-build \
    python3 \
    python3-pip \
    clang \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /simdjson

# Copy the entire repository
COPY . .

# Build simdjson
RUN mkdir -p build && cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DSIMDJSON_BUILD_STATIC_LIB=ON \
    && make -j$(nproc) && \
    make install

# Set the working directory to the repository root
WORKDIR /simdjson

# Default to bash shell
CMD ["/bin/bash"]