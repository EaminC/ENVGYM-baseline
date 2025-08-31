FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install core build tools and curl, git
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup (as root, for simplicity in ephemeral CI/dev)
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set workdir in container
WORKDIR /repo

# Copy everything for build context (multi-project workspace)
COPY . /repo

# Build the workspace for sanity
RUN cargo build --release --workspace || cargo build --workspace

# Default shell entry
CMD ["/bin/bash"]
