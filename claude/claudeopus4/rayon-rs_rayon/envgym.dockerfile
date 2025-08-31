# Build stage for Rayon development environment
FROM rust:1.80-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    vim \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace/rayon

# Copy the entire repository
COPY . .

# Install Rust components
RUN rustup component add rustfmt clippy

# Pre-build dependencies to speed up subsequent builds
RUN cargo fetch
RUN cargo build --all
RUN cargo test --all --no-run

# Set environment variables
ENV RUST_BACKTRACE=1
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# Default command to drop into bash shell
CMD ["/bin/bash"]