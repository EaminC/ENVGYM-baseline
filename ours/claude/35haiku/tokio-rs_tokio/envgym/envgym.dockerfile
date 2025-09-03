FROM rust:slim-bullseye AS builder

# Set environment variables
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.70.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup default stable \
    && rustup update \
    && rustup toolchain install nightly-2025-01-25 \
    && rustup target add x86_64-unknown-linux-gnu

# Set working directory
WORKDIR /tokio-rs_tokio

# Copy project files
COPY . .

# Print contents of target directory before build
RUN ls -R target || true

# Build the project
RUN cargo build --release

# Print contents of target directory after build
RUN ls -R target || true

# Final stage
FROM rust:slim-bullseye

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tokio-rs_tokio

# Copy project files
COPY . .

# Copy build artifacts
COPY --from=builder /tokio-rs_tokio/target /tokio-rs_tokio/target

# Set default shell
CMD ["/bin/bash"]