# Use official Rust image as base
FROM rust:1.74-slim

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /clap

# Copy the entire repository
COPY . /clap

# Install cargo components that might be needed
RUN cargo --version && \
    rustc --version

# Build the project to ensure all dependencies are cached
RUN cargo build --workspace

# Set the default command to bash
CMD ["/bin/bash"]