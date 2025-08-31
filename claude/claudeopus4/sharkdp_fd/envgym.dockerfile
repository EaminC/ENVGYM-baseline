FROM rust:1.77.2-slim

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /fd

# Copy the entire repository
COPY . .

# Build fd
RUN cargo build --release

# Install fd system-wide
RUN cp target/release/fd /usr/local/bin/

# Set the working directory to the repository root
WORKDIR /fd

# Start with bash
CMD ["/bin/bash"]