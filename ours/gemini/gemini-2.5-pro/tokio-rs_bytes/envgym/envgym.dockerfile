# Use a stable Debian-based image like Ubuntu 22.04
FROM ubuntu:22.04

# Set non-interactive mode for package installations and prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Add Cargo's binary directory to the system's PATH for subsequent layers and the final shell
ENV PATH="/root/.cargo/bin:${PATH}"

# Step 0: Install System Dependencies
# Install git, curl, build-essential for compilation, and procps for `nproc`
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Step 1: Install Rust, toolchains, components, and tools in a single layer
# This ensures that rustup, once installed, is available in the PATH for subsequent commands within the same RUN instruction.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    # Source the cargo environment to update the PATH for the current RUN instruction
    . "$HOME/.cargo/env" && \
    # Install the nightly toolchain and its components (Miri, rust-src)
    rustup toolchain install nightly && \
    rustup component add rust-src --toolchain nightly && \
    rustup component add miri --toolchain nightly && \
    # Add the clippy component to the stable toolchain
    rustup component add clippy && \
    # Add cross-compilation targets
    rustup target add \
        thumbv6m-none-eabi \
        thumbv7m-none-eabi \
        mips64-unknown-linux-gnuabi64 \
        x86_64-unknown-linux-gnu && \
    # Install cargo-hack
    cargo install cargo-hack

# Step 2: Set Build Optimization for interactive sessions
# Add CARGO_BUILD_JOBS to .bashrc so it's set dynamically in the final interactive shell
RUN echo 'export CARGO_BUILD_JOBS=$(nproc)' >> /root/.bashrc

# Set the working directory as specified in the plan
WORKDIR /home/cc/EnvGym/data/tokio-rs_bytes

# Copy the project source code into the container
# Assumes the Docker context is the root of the project repository
COPY . .

# Pre-fetch all dependencies to warm up the Cargo cache, making the environment "ready to use"
# This generates a Cargo.lock file if one is not present.
RUN cargo fetch

# Set the default command to launch an interactive bash shell
# The user will be placed in the WORKDIR defined above.
CMD ["/bin/bash"]