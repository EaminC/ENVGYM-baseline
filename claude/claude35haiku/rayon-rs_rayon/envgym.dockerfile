# Rayon development environment Dockerfile
FROM rust:1.80-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /rayon

# Copy the entire repository
COPY . .

# Install project dependencies
RUN cargo fetch

# Set default command to bash
CMD ["/bin/bash"]