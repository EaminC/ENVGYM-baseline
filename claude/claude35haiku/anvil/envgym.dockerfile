# Development environment Dockerfile for Verifiable Controllers

# Use an official Rust image as base
FROM rust:latest

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Clone the Verus dependencies (based on Cargo.toml path dependencies)
RUN git clone https://github.com/verus-lang/verus.git /workspace/verus

# Copy the project files
COPY . /workspace/anvil

# Set working directory to the project root
WORKDIR /workspace/anvil

# Install Rust toolchain
RUN rustup default stable
RUN rustup component add rustfmt clippy

# Build the project dependencies first
RUN cargo build

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]