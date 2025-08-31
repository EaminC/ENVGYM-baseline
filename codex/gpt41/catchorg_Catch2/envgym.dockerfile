FROM ubuntu:20.04

# Non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential cmake python3 python3-pip git \
        && rm -rf /var/lib/apt/lists/*

# Set working directory to repo root
WORKDIR /repo

# Copy repository contents
COPY . /repo

# Build and install Catch2
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j"$(nproc)" && \
    make install

# Default to bash at repo root
WORKDIR /repo
CMD ["/bin/bash"]
