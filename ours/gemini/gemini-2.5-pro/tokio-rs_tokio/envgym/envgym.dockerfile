# Base image: Ubuntu 20.04 as specified in the plan
FROM ubuntu:20.04

# Set non-interactive frontend to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Install Prerequisites
# Consolidate all apt-get operations into a single RUN layer to ensure an updated cache
# and reduce image size by cleaning up afterward.
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    git \
    curl \
    wget \
    pkg-config \
    llvm \
    clang \
    # Libraries
    liburing-dev \
    libssl-dev \
    libelf-dev \
    # Development and testing tools
    valgrind \
    bison \
    flex \
    hunspell-en-us \
    # QEMU for cross-compilation testing
    qemu-system-x86 \
    busybox-static \
    cpio \
    xz-utils \
    # Cross-compilation toolchains
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-i686-linux-gnu \
    g++-i686-linux-gnu \
    musl-tools \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Step 2: Install Rust Toolchain
# Set up environment variables for Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_BACKTRACE=1

# Install rustup and the required toolchains (stable and nightly) and targets
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none \
    && rustup install stable \
    && rustup install nightly \
    && rustup default stable \
    && rustup component add rustfmt clippy \
    && rustup target add aarch64-unknown-linux-gnu \
    && rustup target add i686-unknown-linux-gnu \
    && rustup target add wasm32-wasip1 \
    && rustup target add wasm32-wasip1-threads \
    && rustup target add x86_64-unknown-linux-musl

# Step 3: Install Project-Specific Cargo Tools
# These are installed globally and are independent of the project source code
RUN cargo install cargo-nextest \
    && cargo install cargo-hack \
    && cargo install cargo-spellcheck \
    && cargo install cargo-fuzz \
    && cargo install cargo-deny \
    && cargo install cross \
    && cargo install wasmtime-cli \
    && cargo install wasm-pack \
    && cargo +nightly install cargo-check-external-types --version 0.1.13

# Step 4: Prepare Project for Caching
# Set the working directory
WORKDIR /app

# Copy manifest and configuration files to cache dependencies
COPY Cargo.toml ./
COPY deny.toml ./
COPY spellcheck.toml ./
COPY Cross.toml ./
COPY benches/Cargo.toml ./benches/
COPY examples/Cargo.toml ./examples/
COPY stress-test/Cargo.toml ./stress-test/
COPY tests-build/Cargo.toml ./tests-build/
COPY tests-integration/Cargo.toml ./tests-integration/
COPY tokio/Cargo.toml ./tokio/
COPY tokio/fuzz/Cargo.toml ./tokio/fuzz/
COPY tokio-macros/Cargo.toml ./tokio-macros/
COPY tokio-stream/Cargo.toml ./tokio-stream/
COPY tokio-stream/fuzz/Cargo.toml ./tokio-stream/fuzz/
COPY tokio-test/Cargo.toml ./tokio-test/
COPY tokio-util/Cargo.toml ./tokio-util/

# Create dummy source files for workspace members to allow dependency caching
RUN mkdir -p tokio/src && echo 'pub fn a() {}' > tokio/src/lib.rs && \
    mkdir -p tokio-macros/src && echo 'pub fn a() {}' > tokio-macros/src/lib.rs && \
    mkdir -p tokio-stream/src && echo 'pub fn a() {}' > tokio-stream/src/lib.rs && \
    mkdir -p tokio-test/src && echo 'pub fn a() {}' > tokio-test/src/lib.rs && \
    mkdir -p tokio-util/src && echo 'pub fn a() {}' > tokio-util/src/lib.rs && \
    mkdir -p tests-build/src && echo 'pub fn a() {}' > tests-build/src/lib.rs && \
    mkdir -p tests-integration/src && echo 'pub fn a() {}' > tests-integration/src/lib.rs

# Create local-only configuration files that might affect dependency resolution, including cross-compilation linkers
RUN mkdir -p .cargo && \
    cat <<EOF > .cargo/config.toml
[build]
rustflags = ["--cfg", "tokio_unstable", "--cfg", "tokio_taskdump"]

[target.aarch64-unknown-linux-gnu]
linker = "aarch64-linux-gnu-gcc"

[target.i686-unknown-linux-gnu]
linker = "i686-linux-gnu-gcc"
EOF

# Fetch and build dependencies. This is cached separately from the source code.
# The build may fail on the dummy crates, but cargo will have already
# built all the external dependencies.
RUN cargo build --workspace --all-features || true

# Step 5: Copy remaining source code
# This will overwrite the dummy files with the actual source code.
COPY . .

# Step 6: Build and run the primary test suite
RUN cargo nextest run --workspace --all-features

# Set the final command to start an interactive bash shell in the repository root
CMD ["/bin/bash"]