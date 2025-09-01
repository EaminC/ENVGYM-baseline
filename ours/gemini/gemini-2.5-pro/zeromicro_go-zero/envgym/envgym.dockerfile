# A multi-purpose Dockerfile for a complete Go development environment.
# This image contains all the necessary tools and dependencies to build, test,
# lint, and run the go-zero application as described in the plan.
#
# Usage:
# 1. Build the image: docker build -t go-zero-dev .
# 2. Run a container: docker run -it --rm -v $(pwd):/app go-zero-dev

FROM golang:1.21-bullseye

# Set the working directory inside the container
WORKDIR /app

# Set environment variables from the plan
ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
# Use a proxy for faster Go module downloads, as suggested in the plan
ENV GOPROXY=https://goproxy.cn,direct

# Install system-level dependencies required by the project and build tools
# - bash: For the interactive shell
# - build-essential: C toolchain for compiling Go tools
# - git: For version control
# - make: For running Makefile targets
# - protobuf-compiler: Contains the protoc compiler
# - zip: Required by the goctl cross-compilation build script
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    git \
    make \
    protobuf-compiler \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Go-based development tools globally, independent of the project's go.mod.
# This avoids dependency conflicts with the project's modules.
# These will be installed to $GOPATH/bin, which is already in the PATH.
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN go install go.uber.org/mock/mockgen@latest
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Copy Go module files to establish module context
COPY go.mod go.sum ./

# Download Go module dependencies to leverage Docker layer caching
RUN go mod download

# Copy the entire project source code into the working directory
COPY . .

# Set the default command to start a bash shell.
# This provides an interactive environment inside the container
# with all tools and source code ready to use.
CMD ["/bin/bash"]