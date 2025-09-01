FROM rust:1.70-bullseye

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /bytes

# Copy the entire project
COPY . .

# Install Rust toolchain specified in Cargo.toml
RUN rustup default 1.57

# Install development dependencies
RUN cargo install cargo-watch

# Expose any necessary ports (none needed for this project)

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]