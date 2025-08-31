# envgym.dockerfile - Development environment for cpp-httplib
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install essential packages and dependencies
RUN apt-get update && apt-get install -y \
    # Core development tools
    build-essential \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    pkg-config \
    git \
    curl \
    wget \
    vim \
    nano \
    # C++ compiler and toolchain
    g++ \
    clang \
    # Library dependencies for cpp-httplib
    libssl-dev \
    libcrypto++-dev \
    zlib1g-dev \
    libbrotli-dev \
    libzstd-dev \
    # Additional development tools
    valgrind \
    gdb \
    strace \
    htop \
    tree \
    # Meson build system
    meson \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to the repository root
WORKDIR /cpp-httplib

# Copy the repository contents
COPY . .

# Build the project using CMake (default build)
RUN mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DHTTPLIB_USE_OPENSSL_IF_AVAILABLE=ON \
          -DHTTPLIB_USE_ZLIB_IF_AVAILABLE=ON \
          -DHTTPLIB_USE_BROTLI_IF_AVAILABLE=ON \
          -DHTTPLIB_USE_ZSTD_IF_AVAILABLE=ON \
          -DHTTPLIB_COMPILE=ON \
          -DHTTPLIB_TEST=ON \
          .. && \
    make -j$(nproc)

# Build examples
RUN cd example && \
    make -j$(nproc)

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Set the entry point to bash for interactive use
CMD ["/bin/bash"]