FROM rust:1.88-bookworm

# Install build dependencies and useful tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libpcre2-dev \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /ripgrep

# Copy the entire repository
COPY . .

# Build ripgrep with all features including PCRE2
RUN cargo build --release --features pcre2

# Install ripgrep to system path
RUN cp target/release/rg /usr/local/bin/

# Set up shell environment
ENV SHELL=/bin/bash

# Default command is bash
CMD ["/bin/bash"]