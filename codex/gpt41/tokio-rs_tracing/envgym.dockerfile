FROM ubuntu:20.04

# Arguments for noninteractive setup
ARG DEBIAN_FRONTEND=noninteractive

# Environment for bash at root
ENV HOME=/root
ENV USER=root
WORKDIR /home/cc/data/tokio-rs_tracing

# Install base utilities and build deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        ca-certificates \
        pkg-config \
        libssl-dev \
        libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain (stable, cargo)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain stable
ENV PATH=$PATH:/root/.cargo/bin

# Copy repo contents
COPY . /home/cc/data/tokio-rs_tracing

# Build whole workspace (fail early)
RUN cargo build --release

# Bash shell at repo root
ENTRYPOINT ["/bin/bash"]
