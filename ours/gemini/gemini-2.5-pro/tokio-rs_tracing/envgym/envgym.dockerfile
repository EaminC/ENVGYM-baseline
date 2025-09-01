# Use a modern Ubuntu LTS release as the base image
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Install System Dependencies
# Install Git, systemd development libraries, curl, and essential build tools.
# Clean up apt cache to reduce image size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libsystemd-dev \
    curl \
    pkg-config \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Add cargo to the PATH for subsequent commands. This is set before the install
# so it's available for all subsequent layers.
ENV PATH="/root/.cargo/bin:${PATH}"

# Step 2: Install Rust, toolchains, and cargo tools in a single layer.
# This ensures that the PATH is correctly updated by rustup and available for all
# subsequent commands within this single RUN instruction.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rustup toolchain install stable && \
    rustup toolchain install 1.49.0 && \
    rustup toolchain install 1.63.0 && \
    rustup toolchain install 1.64.0 && \
    rustup toolchain install 1.65.0 && \
    rustup toolchain install nightly && \
    rustup component add rustfmt clippy && \
    rustup target add wasm32-unknown-unknown && \
    cargo install cargo-nextest && \
    cargo install cargo-hack && \
    cargo install cargo-minimal-versions && \
    cargo install wasm-pack && \
    cargo install cargo-audit && \
    cargo install trybuild

# Set the working directory for the project
WORKDIR /home/cc/EnvGym/data/tokio-rs_tracing

# Copy the project source code into the working directory
COPY . .

# Step 3: Check Workspace Compilation and Build Dependencies
# This generates the Cargo.lock file and pre-compiles all dependencies,
# caching them in this layer to speed up subsequent builds and tests.
RUN cargo check --all --tests --benches && \
    (cd tracing/test_static_max_level_features && cargo check)

# Set the default command to an interactive bash shell.
# When the container runs, the user will be at the project root,
# with all tools installed and dependencies built, ready to work.
CMD ["/bin/bash"]