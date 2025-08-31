# Use the official Rust image as base
FROM rust:1.57-slim

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Install the library and run tests to ensure everything is set up correctly
RUN cargo build --all-features
RUN cargo test --all-features

# Set the default command to bash
CMD ["/bin/bash"]