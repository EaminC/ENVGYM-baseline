FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG GO_VERSION=1.24.0

# Base system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    gcc \
    clang \
    make \
    pkg-config \
    software-properties-common \
    ca-certificates \
    gnupg \
    golang-go \
    libssl-dev

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh

# Install Go specific version
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

# Install Go tools and linters
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Create workspace
WORKDIR /workspace

# Copy repository contents
COPY . /workspace

# Create build directories
RUN mkdir -p /workspace/bin /workspace/build

# Set default shell
SHELL ["/bin/bash", "-c"]

# Default command
CMD ["/bin/bash"]