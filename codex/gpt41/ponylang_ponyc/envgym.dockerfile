# Ubuntu 20.04 base image
FROM ubuntu:20.04

# Set DEBIAN_FRONTEND to noninteractive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: build tools, CMake, Clang, Python3, Git, others needed for Pony
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    git \
    cmake \
    python3 \
    python3-pip \
    wget \
    curl \
    ninja-build \
    lsb-release \
    ca-certificates && rm -rf /var/lib/apt/lists/*

# Create working directory for repo
WORKDIR /ponylang_ponyc

# Copy contents of repo into container
COPY . /ponylang_ponyc

# Build Pony from source (vendored LLVM, build ponyc)
RUN make libs build_flags="-j$(nproc)" && \
    make configure && \
    make build && \
    make install

# Entrypoint: /bin/bash
ENTRYPOINT ["/bin/bash"]
