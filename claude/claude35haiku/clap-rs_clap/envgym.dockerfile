FROM rust:latest

# Install additional tools
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /clap-rs

# Copy the entire repository
COPY . .

# Install any project-specific dependencies
RUN cargo build

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]