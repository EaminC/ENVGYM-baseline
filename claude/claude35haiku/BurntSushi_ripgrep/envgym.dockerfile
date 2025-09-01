FROM rust:1.88-slim-bullseye

# Install necessary build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /ripgrep

# Copy the entire repository
COPY . .

# Build the project
RUN cargo build --release

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]