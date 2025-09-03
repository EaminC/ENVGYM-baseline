FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    bash \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default 1.87.0 && \
    rustup target add wasm32-unknown-unknown && \
    rustup component add rustfmt clippy

# Install GitHub Actions runner dependencies
RUN pip3 install virtualenv

# Set working directory
WORKDIR /repository

# Copy repository contents
COPY . .

# Install Nushell
RUN cargo build --release

# Set default shell
ENTRYPOINT ["/bin/bash"]