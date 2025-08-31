# Use the official Rust image as base
FROM rust:latest

# Install additional development tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Install Rust components
RUN rustup component add rustfmt clippy

# Build the project to cache dependencies
RUN cargo build --all

# Set the default command to bash
CMD ["/bin/bash"]