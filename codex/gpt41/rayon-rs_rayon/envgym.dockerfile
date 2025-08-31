# Start with official Rust image
FROM rust:1.80

# Enable noninteractive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and useful packages
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    git \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Set workdir to repo root
WORKDIR /work

# Copy everything
COPY . .

# Build the rayon package and workspace members
RUN cargo build --release

# Set shell entrypoint and start in /work
ENTRYPOINT ["/bin/bash"]
WORKDIR /work
