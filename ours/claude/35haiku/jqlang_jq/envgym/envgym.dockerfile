FROM debian:12-slim AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM=linux/amd64

# Fundamental system updates and core tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    libtool \
    make \
    automake \
    autoconf \
    bison \
    flex \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    valgrind \
    clang \
    gcc-11 \
    libonig-dev

# Install jq from source
WORKDIR /tmp/jq
RUN wget https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-1.8.1.tar.gz && \
    tar -xzf jq-1.8.1.tar.gz && \
    cd jq-1.8.1 && \
    ./configure && \
    make && \
    make install

# Python environment setup with improved error handling
RUN python3 -m pip install --break-system-packages --upgrade pip setuptools wheel && \
    python3 -m pip install --break-system-packages pipenv virtualenv

# Set working directory
WORKDIR /jqlang_jq

# Copy project files
COPY . .

# Prepare build environment
RUN autoreconf -fi && \
    ./configure && \
    make

# Cleanup and finalize
RUN rm -rf /var/lib/apt/lists/* /tmp/*

# Default command
CMD ["/bin/bash"]