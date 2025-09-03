FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Core build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    cmake \
    git \
    python3 \
    python3-pip \
    ninja-build \
    meson \
    pkg-config \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Compilers
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-7 \
    g++-7 \
    gcc-8 \
    g++-8 \
    gcc-9 \
    g++-9 \
    gcc-10 \
    g++-10 \
    clang-10 \
    clang-11 \
    clang-12 \
    && rm -rf /var/lib/apt/lists/*

# Development libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    zlib1g-dev \
    liblz4-dev \
    liblzma-dev \
    valgrind \
    libc6-dev-i386 \
    gcc-multilib \
    g++-multilib \
    && rm -rf /var/lib/apt/lists/*

# Cross-compilation tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-arm-linux-gnueabi \
    g++-arm-linux-gnueabi \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Essential utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    file \
    ccache \
    tar \
    gzip \
    unzip \
    patch \
    diffutils \
    findutils \
    grep \
    sed \
    gawk \
    coreutils \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Set up alternatives
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 100

# Python setup
RUN pip3 install --upgrade pip setuptools wheel

# Git config
RUN git config --global user.email "docker@example.com" \
    && git config --global user.name "Docker User" \
    && git config --global core.autocrlf false

# Create workspace
RUN mkdir -p /workspace
WORKDIR /workspace

# Clone the repository
RUN git clone https://github.com/facebook/zstd.git .

# Environment variables
ENV MAKEFLAGS="-j$(nproc)"
ENV CCACHE_DIR=/workspace/.ccache
ENV PATH=/usr/lib/ccache:$PATH

CMD ["/bin/bash"]