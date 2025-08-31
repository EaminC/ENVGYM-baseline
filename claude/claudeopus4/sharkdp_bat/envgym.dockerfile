# Build stage
FROM rust:1.74-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libgit2-dev \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy the entire repository
COPY . .

# Build bat in release mode
RUN cargo build --release --locked

# Runtime stage
FROM ubuntu:20.04

# Avoid timezone prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies and useful tools
RUN apt-get update && apt-get install -y \
    git \
    less \
    curl \
    vim \
    nano \
    build-essential \
    pkg-config \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain for development
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.74
ENV PATH="/root/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace/bat

# Copy the repository
COPY . .

# Copy the built binary from builder stage
COPY --from=builder /build/target/release/bat /usr/local/bin/bat

# Set up shell environment
ENV SHELL=/bin/bash

# Default command is bash
CMD ["/bin/bash"]