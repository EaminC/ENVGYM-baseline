# Dockerfile for Nushell development environment
FROM rust:1.87.0 AS builder

# Set working directory
WORKDIR /usr/src/nushell

# Copy the entire project
COPY . .

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build the project in release mode
RUN cargo build --release

# Final stage
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /usr/src/nushell/target/release/nu /usr/local/bin/nu

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]