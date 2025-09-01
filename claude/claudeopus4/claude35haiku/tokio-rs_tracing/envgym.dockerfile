# Dockerfile for tracing repository development environment
FROM rust:latest

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Install Rust toolchain and components
RUN rustup update && \
    rustup component add rustfmt clippy

# Build the workspace
RUN cargo build

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]