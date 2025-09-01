FROM rust:1.77.2-slim-bullseye

# Install essential build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /fd

# Copy the entire project
COPY . .

# Build the project
RUN cargo build --release

# Install the binary
RUN cargo install --path .

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]