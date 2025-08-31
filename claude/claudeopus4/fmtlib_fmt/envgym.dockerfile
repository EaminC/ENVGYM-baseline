# Use Ubuntu 20.04 as base image to match the current environment
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    g++ \
    clang \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /fmt

# Copy the entire repository
COPY . /fmt

# Build fmt library
RUN mkdir -p build && cd build && \
    cmake .. \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DFMT_TEST=OFF \
        -DFMT_DOC=OFF && \
    ninja

# Install the library system-wide
RUN cd build && ninja install

# Set the working directory to the repository root
WORKDIR /fmt

# Default command is bash
CMD ["/bin/bash"]