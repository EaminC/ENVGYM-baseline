FROM rust:1.75-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN rustup update && \
    rustup toolchain install stable && \
    rustup toolchain install 1.57 && \
    rustup toolchain install nightly && \
    rustup default stable && \
    rustup component add rust-src --toolchain nightly && \
    rustup target add thumbv6m-none-eabi thumbv7m-none-eabi i686-unknown-linux-gnu wasm32-wasip1

RUN cargo install cargo-edit cargo-watch cargo-tarpaulin cargo-hack

WORKDIR /workspace

COPY Cargo.toml ./
COPY clippy.toml ./
COPY LICENSE ./
COPY README.md ./
COPY CHANGELOG.md ./
COPY SECURITY.md ./
COPY src ./src
COPY tests ./tests
COPY benches ./benches
COPY ci ./ci

RUN chmod +x ci/*.sh

RUN cargo fetch

CMD ["/bin/bash"]