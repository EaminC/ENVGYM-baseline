FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG RUST_VERSION=1.88.0
ARG GO_VERSION=1.20.14
ARG VERUS_COMMIT=3b6b805ac86cd6640d59468341055c7fa14cff07
ARG KIND_VERSION=0.23.0

WORKDIR /anvil

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    software-properties-common \
    python3 \
    python3-pip \
    libssl-dev \
    pkg-config \
    zlib1g-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

# Install additional Rust tools
RUN cargo install cargo-watch cargo-verify

# Install Python dependencies
RUN pip3 install tabulate

# Install Z3 SMT solver
RUN apt-get update && apt-get install -y z3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Kubernetes tools
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Clone and build Verus with improved error handling
RUN mkdir -p /anvil/verus && \
    cd /anvil/verus && \
    git clone https://github.com/verus-lang/verus.git . 2>&1 | tee git_clone.log && \
    git fetch origin ${VERUS_COMMIT} 2>&1 | tee git_fetch.log && \
    git checkout ${VERUS_COMMIT} 2>&1 | tee git_checkout.log && \
    cargo build --release 2>&1 | tee cargo_build.log

# Set environment paths
ENV PATH="/usr/local/go/bin:${PATH}"
ENV RUST_HOME="/root/.cargo"
ENV VERUS_HOME="/anvil/verus"

# Clone the Anvil repository with retry and verbose logging
RUN mkdir -p /anvil/repository && \
    cd /anvil/repository && \
    (for i in 1 2 3; do \
        git clone https://github.com/microsoft/anvil.git . && break || \
        echo "Clone attempt $i failed, retrying..." && \
        sleep 5; \
    done) 2>&1 | tee git_clone_log.txt

WORKDIR /anvil/repository

CMD ["/bin/bash"]