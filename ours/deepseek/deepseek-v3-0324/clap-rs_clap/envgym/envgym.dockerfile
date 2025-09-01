FROM rust:1.74-slim-bullseye

ENV CARGO_BUILD_JOBS=$(nproc) \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    STABLE=1.89 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN rustup toolchain install stable-x86_64-unknown-linux-gnu && \
    rustup default stable-x86_64-unknown-linux-gnu && \
    rustup component add rustfmt clippy && \
    rustup target add wasm32-unknown-unknown --toolchain stable-x86_64-unknown-linux-gnu

WORKDIR /clap-rs_clap

COPY . .

RUN mkdir -p .cargo && \
    echo '[target.x86_64-unknown-linux-gnu]\nlinker = "cc"' > .cargo/config.toml

RUN cargo generate-lockfile && \
    cargo update --verbose && \
    cargo fetch --verbose

RUN echo "Building dependencies..." && \
    RUST_BACKTRACE=full cargo build --verbose --manifest-path=clap_builder/Cargo.toml && \
    RUST_BACKTRACE=full cargo build --verbose --manifest-path=clap_derive/Cargo.toml && \
    RUST_BACKTRACE=full cargo build --verbose --manifest-path=clap_lex/Cargo.toml

RUN echo "Building workspace..." && \
    RUST_BACKTRACE=full cargo build --verbose --workspace --all-targets

RUN echo "Testing workspace..." && \
    RUST_BACKTRACE=full cargo test --no-run --verbose --workspace --all-targets

RUN rustc --version --verbose | grep host && \
    du -sh /clap-rs_clap && \
    df -h

CMD ["/bin/bash"]