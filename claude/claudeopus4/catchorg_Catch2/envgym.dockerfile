FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    clang \
    git \
    python3 \
    python3-pip \
    ninja-build \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/

# Configure and build Catch2
RUN mkdir -p /workspace/build && \
    cd /workspace/build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCATCH_BUILD_TESTING=OFF \
        -DCATCH_BUILD_EXAMPLES=OFF \
        -DCATCH_BUILD_EXTRA_TESTS=OFF \
        -DCATCH_ENABLE_COVERAGE=OFF \
        -DCATCH_INSTALL_DOCS=ON \
        -DCATCH_INSTALL_EXTRAS=ON && \
    cmake --build . -j$(nproc) && \
    cmake --install .

# Clean up build directory to save space
RUN rm -rf /workspace/build

# Set the working directory to the repository root
WORKDIR /workspace

# Default command is bash
CMD ["/bin/bash"]