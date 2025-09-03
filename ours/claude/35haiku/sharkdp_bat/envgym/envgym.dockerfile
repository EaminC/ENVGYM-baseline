FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    gcc \
    g++ \
    clang \
    llvm \
    pkg-config \
    libssl-dev \
    ca-certificates

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.74.0

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --default-toolchain ${RUST_VERSION} \
    --profile minimal \
    --target x86_64-unknown-linux-gnu

RUN rustup component add rustfmt || echo "Failed to install rustfmt" && \
    rustup component add cargo-audit || echo "Failed to install cargo-audit"

RUN mkdir -p /workspace
WORKDIR /workspace

COPY . .

RUN cargo build --release --target x86_64-unknown-linux-gnu

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/cargo /usr/local/bin/
COPY --from=builder /usr/local/rustup/toolchains/*/bin/rustc /usr/local/bin/
COPY --from=builder /workspace/target/x86_64-unknown-linux-gnu/release/bat /usr/local/bin/

WORKDIR /workspace
CMD ["/bin/bash"]