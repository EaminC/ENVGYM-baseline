FROM ubuntu:22.04

# Set working directory
WORKDIR /anvil

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    curl \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust with the specific version from rust-toolchain.toml
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.88.0

# Set environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Go (required for e2e tests and some tooling)
RUN wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz && \
    rm go1.20.14.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Install Kind for Kubernetes testing
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# Install kubectl (useful for interacting with Kubernetes)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Docker CLI (needed for Kind)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire repository
COPY . /anvil

# Set up Verus as a dependency (assuming it should be at ../verus relative to the repo)
WORKDIR /
RUN git clone https://github.com/verus-lang/verus.git && \
    cd verus && \
    git checkout 8bd7c3292aad57d3926ed8024cde13ca53d6e1a7 && \
    cd source && \
    ./tools/get-z3.sh && \
    source ../tools/activate && \
    /root/.cargo/bin/cargo build --release

# Set environment variable for Verus
ENV VERUS_DIR=/verus

# Return to the anvil directory
WORKDIR /anvil

# Default command to start bash
CMD ["/bin/bash"]