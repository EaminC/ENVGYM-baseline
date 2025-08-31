# Base image with Go 1.24
FROM golang:1.24-alpine AS builder

# Install required build dependencies
RUN apk add --no-cache \
    git \
    make \
    gcc \
    musl-dev \
    bash

# Set working directory
WORKDIR /build

# Copy go mod files first for better caching
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire repository
COPY . .

# Build the gh binary
RUN make bin/gh

# Final stage - Ubuntu-based for bash environment
FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Copy the built binary from builder stage
COPY --from=builder /build/bin/gh /usr/local/bin/gh

# Set working directory to repository root
WORKDIR /cli

# Copy the entire repository (for access to scripts, docs, etc.)
COPY . .

# Ensure gh binary is executable
RUN chmod +x /usr/local/bin/gh

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default command is bash
CMD ["/bin/bash"]