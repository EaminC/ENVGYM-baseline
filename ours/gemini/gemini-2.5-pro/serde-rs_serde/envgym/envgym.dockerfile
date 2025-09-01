FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ca-certificates \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none --no-modify-path \
    && rustup toolchain install stable nightly 1.61 \
    && rustup component add clippy --toolchain stable \
    && rustup component add clippy --toolchain nightly \
    && rustup component add clippy --toolchain 1.61 \
    && rustup component add miri --toolchain nightly \
    && rustup default stable

RUN cargo install cargo-docs-rs cargo-outdated

WORKDIR /home/cc/EnvGym/data/serde-rs_serde

RUN git clone https://github.com/serde-rs/serde.git .

RUN cargo build --workspace

CMD ["/bin/bash"]