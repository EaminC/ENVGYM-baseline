# Use a recent stable Debian/Ubuntu base image for linux/amd64
FROM ubuntu:22.04

# Set environment variables to enable non-interactive installation and configure Rust
ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    PCRE2_SYS_STATIC=1

# Install system dependencies required for building and testing ripgrep
# Includes Git, C compiler, PCRE2, and tools for testing compressed files
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libpcre2-dev \
    pkg-config \
    zsh \
    xz-utils \
    liblz4-tool \
    musl-tools \
    brotli \
    zstd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Rust toolchain and rustfmt component
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    $CARGO_HOME/bin/rustup component add rustfmt

# Create the specified working directory structure
RUN mkdir -p /home/cc/EnvGym/data

# Clone the ripgrep repository into the specified directory
RUN git clone https://github.com/BurntSushi/ripgrep.git /home/cc/EnvGym/data/BurntSushi_ripgrep

# Set the final working directory to the root of the cloned repository
WORKDIR /home/cc/EnvGym/data/BurntSushi_ripgrep

# Perform an official release build to make the binary available and "ready to use"
# This build will use all available CPU cores on the host machine.
# The PCRE2_SYS_STATIC=1 env var ensures static linking.
RUN cargo build --release --workspace --features pcre2

# Set the default command to start a bash shell in the working directory
CMD ["/bin/bash"]