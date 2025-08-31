# Dockerfile for tracing repository development environment
FROM rust:1.80-bookworm

# Install additional dependencies that might be needed
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to repository root
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Build the workspace to ensure everything compiles
RUN cargo build --workspace

# Set the default command to bash
CMD ["/bin/bash"]