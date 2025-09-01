# Development environment Dockerfile for gRPC Go
FROM golang:1.24.0-bullseye

# Install essential tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /grpc

# Copy the entire repository
COPY . .

# Install Go dependencies
RUN go mod download

# Set up environment variables
ENV GO111MODULE=on \
    CGO_ENABLED=1

# Default command to start a bash shell
CMD ["/bin/bash"]