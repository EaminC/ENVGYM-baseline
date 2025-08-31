# Multi-stage Dockerfile for grpc-go development environment
# Builds the repository and provides a bash CLI at the repository root

# Build stage
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk --no-cache add \
    bash \
    curl \
    git \
    make \
    gcc \
    musl-dev \
    protobuf \
    protobuf-dev

# Set working directory
WORKDIR /go/src/grpc-go

# Copy the entire repository
COPY . .

# Download dependencies
RUN go mod download

# Build all packages to ensure everything compiles
RUN go build -tags osusergo,netgo google.golang.org/grpc/...

# Development stage
FROM golang:1.25-alpine

# Install runtime dependencies and development tools
RUN apk --no-cache add \
    bash \
    curl \
    git \
    make \
    gcc \
    musl-dev \
    protobuf \
    protobuf-dev \
    vim \
    less

# Set working directory to match repository location
WORKDIR /go/src/grpc-go

# Copy the repository from build stage
COPY --from=builder /go/src/grpc-go .

# Copy Go module cache from builder to speed up future builds
COPY --from=builder /go/pkg /go/pkg

# Set environment variables for gRPC
ENV GRPC_GO_LOG_VERBOSITY_LEVEL=99
ENV GRPC_GO_LOG_SEVERITY_LEVEL=info

# Download and install development tools used by the repository
RUN go install golang.org/x/tools/cmd/goimports@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest && \
    go install github.com/client9/misspell/cmd/misspell@latest && \
    go install github.com/mgechev/revive@latest

# Ensure go mod cache is populated
RUN go mod download

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default command is bash
CMD ["/bin/bash"]