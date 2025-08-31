# Dockerfile for nlohmann/json development environment
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    g++ \
    clang \
    ninja-build \
    python3 \
    python3-pip \
    wget \
    curl \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/

# Create build directory
RUN mkdir -p build

# Configure and build the project
RUN cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DJSON_BuildTests=OFF \
    -DJSON_Install=ON && \
    make -j$(nproc) && \
    make install

# Clean up build artifacts to reduce image size (optional)
RUN rm -rf build

# Set the default command to bash
CMD ["/bin/bash"]