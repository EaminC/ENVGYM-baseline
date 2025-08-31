FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl wget unzip build-essential pkg-config libssl-dev ca-certificates

# Install Rust toolchain (1.88.0)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain 1.88.0
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone Verus at required release (needed for build)
ARG VERUS_VER=release/0.2025.07.05.8bd7c32
RUN git clone https://github.com/verus-lang/verus.git /verus && \
    cd /verus && git checkout ${VERUS_VER} && \
    ./tools/get-z3.sh && \
    source tools/activate && \
    vargo build --release || true

# Create workspace
WORKDIR /anvil
COPY . /anvil

# Build repo dependencies (for local libs)
RUN . /root/.cargo/env && cd src/deps_hack && cargo build --release && cd /anvil

# Default shell when run
ENTRYPOINT ["/bin/bash"]
