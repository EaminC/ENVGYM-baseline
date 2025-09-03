FROM rust:1.74.0-bullseye AS builder

# Set environment variables
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN rustup default stable \
    && rustup component add rustfmt clippy

# Install cargo packages individually with error handling
RUN cargo install --locked cargo-deny || true
RUN cargo install --locked cargo-release || true
RUN cargo install --locked typos || true
RUN cargo install --locked pre-commit || true
RUN cargo install --locked bindgen || true
RUN cargo install --locked divan || true
RUN cargo install --locked clap-cargo || true

# Set working directory
WORKDIR /clap-rs_clap

# Copy project files
COPY . .

# Build project
RUN cargo build --release

FROM rust:1.74.0-bullseye

# Copy artifacts from builder
COPY --from=builder /usr/local/cargo /usr/local/cargo
COPY --from=builder /clap-rs_clap /clap-rs_clap

# Set working directory
WORKDIR /clap-rs_clap

# Set environment paths
ENV PATH=/usr/local/cargo/bin:$PATH

# Default command
CMD ["/bin/bash"]