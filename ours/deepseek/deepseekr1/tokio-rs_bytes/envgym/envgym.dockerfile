FROM ubuntu:22.04

WORKDIR /home/cc/EnvGym/data/tokio-rs_bytes

RUN apt-get update && \
    apt-get install -y git \
    gcc-i686-linux-gnu \
    gcc-arm-linux-gnueabihf \
    gcc-powerpc-linux-gnu \
    gcc-powerpc64-linux-gnu \
    curl \
    build-essential

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup toolchain install nightly-2024-09-15 && \
    rustup target add thumbv6m-none-eabi thumbv7m-none-eabi wasm32-unknown-unknown i686-unknown-linux-gnu armv7-unknown-linux-gnueabihf powerpc-unknown-linux-gnu powerpc64-unknown-linux-gnu wasm32-wasip1

COPY . .

RUN if [ ! -f Cargo.toml ]; then \
    echo '[dependencies]' > Cargo.toml && \
    echo 'bytes = { version = "1.10.1", default-features = false }' >> Cargo.toml; \
    fi

RUN mkdir -p src && \
    if [ ! -f src/main.rs ]; then \
    echo 'use bytes::{Bytes, BytesMut, Buf, BufMut};' > src/main.rs; \
    fi

RUN cargo install cargo-hack

RUN cargo build --verbose 2>&1 | tee build.log || { cat build.log; exit 1; }

RUN cargo clean && \
    rm -rf target/*/release

CMD ["/bin/bash"]