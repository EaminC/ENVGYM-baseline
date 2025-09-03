FROM rust:1.57.0-bullseye AS builder

# Set environment variables
ENV RUST_HOME=/usr/local/rust
ENV RUSTUP_HOME=${RUST_HOME}/rustup
ENV CARGO_HOME=${RUST_HOME}/cargo
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    gcc \
    musl-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup default stable \
    && rustup update \
    && rustup component add \
    rust-src \
    rustfmt \
    clippy \
    && rustup target add \
    x86_64-unknown-linux-gnu \
    x86_64-unknown-linux-musl \
    wasm32-wasip1

# Install additional Rust tools
RUN cargo install cargo-hack || true

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build and test project
RUN cargo build --release \
    && cargo test --release

# Final stage
FROM rust:1.57.0-slim-bullseye

# Copy artifacts from builder
COPY --from=builder /usr/local/rust /usr/local/rust
COPY --from=builder /app /app

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]