# Dockerfile for Tokio repository development environment
FROM rust:latest

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tokio

# Copy the entire repository
COPY . .

# Install Rust components
RUN rustup update \
    && rustup component add rustfmt clippy

# Build the workspace
RUN cargo build --workspace

# Set default command to bash
CMD ["/bin/bash"]