FROM rust:1.74-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /bat

# Copy the entire project
COPY . .

# Install project dependencies
RUN cargo build

# Default command to launch bash
CMD ["/bin/bash"]