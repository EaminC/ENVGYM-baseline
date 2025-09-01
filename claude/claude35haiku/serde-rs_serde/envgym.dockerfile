# Dockerfile for Serde Rust development environment
FROM rust:latest

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential

# Set working directory
WORKDIR /serde

# Copy the entire repository
COPY . .

# Install cargo-watch for development
RUN cargo install cargo-watch

# Set up the environment
RUN rustup component add rustfmt clippy

# Default command to start a bash shell
CMD ["/bin/bash"]