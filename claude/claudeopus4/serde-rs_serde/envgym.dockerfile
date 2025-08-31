# Use Ubuntu 20.04 as base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=1.56.0

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace

# Build the project to download dependencies
RUN cargo build --all

# Set the default command to bash
CMD ["/bin/bash"]