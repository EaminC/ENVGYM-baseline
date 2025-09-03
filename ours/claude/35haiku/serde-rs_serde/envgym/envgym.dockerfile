FROM rust:slim-bullseye AS builder

ARG TARGETPLATFORM=linux/amd64
ARG RUST_VERSION=1.74.0

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_BACKTRACE=1 \
    RUSTFLAGS="-C target-cpu=native"

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN rustup default stable \
    && rustup target add x86_64-unknown-linux-gnu \
    && rustup target add x86_64-unknown-linux-musl \
    && rustup component add rust-src rustfmt clippy rust-analyzer

COPY . .

RUN cargo build --release --verbose 2>&1 | tee build.log \
    && cargo test --release --verbose 2>&1 | tee test.log

FROM rust:slim-bullseye

WORKDIR /workspace/serde-rs_serde

COPY --from=builder /workspace/target/release/ /usr/local/bin/
COPY --from=builder /workspace/build.log /workspace/test.log ./
COPY . .

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV RUST_BACKTRACE=1 \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

VOLUME ["/workspace/serde-rs_serde"]

CMD ["/bin/bash"]