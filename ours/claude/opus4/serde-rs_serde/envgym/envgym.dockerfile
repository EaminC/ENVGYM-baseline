FROM rust:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchains one by one
RUN rustup toolchain install 1.56.0
RUN rustup toolchain install 1.60.0
RUN rustup toolchain install 1.61.0
RUN rustup toolchain install 1.64.0
RUN rustup toolchain install 1.74.0
RUN rustup toolchain install 1.77.0
RUN rustup toolchain install 1.78.0
RUN rustup toolchain install 1.81.0
RUN rustup toolchain install beta
RUN rustup toolchain install nightly

# Set default toolchain
RUN rustup default stable

# Add components
RUN rustup component add rustfmt clippy
RUN rustup +nightly component add miri

# Add targets
RUN rustup target add thumbv7m-none-eabi
RUN rustup target add wasm32-unknown-emscripten

# Install cargo extensions
RUN cargo install cargo-watch cargo-expand cargo-outdated cargo-workspaces cargo-readme cargo-msrv cargo-docs-rs

# Set working directory
WORKDIR /home/cc/EnvGym/data/serde-rs_serde

# Copy all files
COPY . .

# Set up environment
ENV RUST_BACKTRACE=1

# Start bash shell
CMD ["/bin/bash"]