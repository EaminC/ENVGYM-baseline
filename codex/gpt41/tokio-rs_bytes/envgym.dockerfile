FROM rust:1.57-bullseye

# Install common dev tools
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    git \
    vim \
    bash

# Set workdir to repo root
WORKDIR /workspace

# Copy repo contents
COPY . /workspace

# Install dependencies (fetch crates)
RUN cargo fetch \
 && cargo build --release

# Default to bash at repo root
CMD ["/bin/bash"]
