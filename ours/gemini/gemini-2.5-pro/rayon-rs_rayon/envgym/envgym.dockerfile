# Use the official Rust image corresponding to the required version 1.80.0
# This Debian-based image includes build-essential and other common tools.
FROM rust:1.80.0

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Install system-level dependencies as specified in the plan
# Includes build tools, graphics libraries for demos, and multilib for i686 cross-compilation.
# Also install git and curl which are required for other steps.
RUN apt-get update && apt-get install -y \
    pkg-config \
    libgtk-3-dev \
    libx11-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libssl-dev \
    gcc-multilib \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Step 1 (cont.): Install required Rust toolchains, components, and targets via rustup
RUN rustup component add rustfmt && \
    rustup toolchain install beta && \
    rustup toolchain install nightly && \
    rustup target add i686-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown && \
    rustup target add wasm32-wasip1

# Step 3b: Install Wasmtime v35.0.0 for running WASI tests
RUN curl https://wasmtime.dev/install.sh -sSf | bash -s -- --version v35.0.0

# Configure environment variables for the build environment
# Add wasmtime and cargo to the PATH
ENV PATH="/root/.cargo/bin:/root/.wasmtime/bin:${PATH}"
# Set the minimum stack size to replicate CI environment and prevent overflows
ENV RUST_MIN_STACK=16777216
# Set the runner for the wasm32-wasip1 target so `cargo test` works out of the box
ENV CARGO_TARGET_WASM32_WASIP1_RUNNER="/root/.wasmtime/bin/wasmtime"

# Add build job optimization to the bash profile for interactive sessions
RUN echo 'export CARGO_BUILD_JOBS=$(nproc)' >> /root/.bashrc

# Set the working directory to match the project structure
WORKDIR /home/cc/EnvGym/data/rayon-rs_rayon

# Copy the entire project context into the working directory
# Assumes the Dockerfile is at the root of the rayon-rs_rayon repository
COPY . .

# Set the default command to start a bash shell.
# When the container runs, the user will be in an interactive shell
# at `/home/cc/EnvGym/data/rayon-rs_rayon`, ready to run cargo commands.
CMD ["/bin/bash"]