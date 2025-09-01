# Use Ubuntu 22.04 as the base image, recommended for glibc compatibility.
FROM ubuntu:22.04

# Set non-interactive mode for package installations to prevent prompts.
ENV DEBIAN_FRONTEND=noninteractive

# Install all system dependencies required for building Nushell from source.
# This includes the C/C++ toolchain, git, development libraries, Python, and other tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libclang-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libzstd-dev \
    devscripts \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    mold \
    curl \
    wget \
    python3.10 \
    python3-pip \
    python3.10-venv \
    # Clean up apt cache to reduce final image size.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python virtualenv and pre-commit using pip.
RUN pip3 install --no-cache-dir virtualenv pre-commit

# Install rustup (the Rust toolchain manager) and set environment variables.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none

# Set up the working directory for the project.
WORKDIR /app

# Clone the Nushell repository. The .git directory is required by build scripts.
RUN git clone https://github.com/nushell/nushell.git .

# Let rustup install the specific toolchain version defined in rust-toolchain.toml.
# This is triggered automatically by running a cargo command.
RUN cargo version

# Install optional but useful developer tools via cargo.
# This is done before the main project build to better leverage Docker layer caching.
RUN cargo install typos-cli cargo-audit cargo-tarpaulin cargo-fuzz cross

# Build the entire Nushell project in release mode for performance.
# The `git` command is used by build scripts to embed version info into the binary.
# Using --locked ensures a reproducible build based on the committed Cargo.lock file.
RUN cargo build --release --locked

# Add the compiled binaries to the PATH so `nu` and plugins can be run directly.
ENV PATH="/app/target/release:${PATH}"

# Set the default command to a bash shell, placing the user at the root of the repository,
# with the environment fully configured and the project built and ready to use.
CMD ["/bin/bash"]