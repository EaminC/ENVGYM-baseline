FROM golang:1.25-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies:
# - procps: for `nproc` used in the Makefile
# - unzip: for scripts that download and extract archives (e.g., protoc)
# - docker-cli: to build containerized examples and tests
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    procps \
    unzip \
    docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Set up the workspace and clone the repository
WORKDIR /workspace
RUN git clone https://github.com/grpc/grpc-go.git grpc-go
WORKDIR /workspace/grpc-go

# Add Go's binary directory to the PATH for installed tools
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Download all Go module dependencies for the entire multi-module repository
RUN go mod download

# Install all Go-based development and verification tools (linters, etc.)
RUN make vetdeps

# Install the full Protocol Buffers toolchain (protoc, go-plugins) by running
# the project's comprehensive regeneration script. This also ensures all
# generated .pb.go files are up-to-date within the image.
RUN ./scripts/regenerate.sh

# Set environment variables for verbose, JSON-formatted gRPC logging by default
ENV GRPC_GO_LOG_VERBOSITY_LEVEL=99
ENV GRPC_GO_LOG_SEVERITY_LEVEL=info
ENV GRPC_GO_LOG_FORMATTER=json

# Provide an interactive bash shell in the project's root directory
CMD ["/bin/bash"]