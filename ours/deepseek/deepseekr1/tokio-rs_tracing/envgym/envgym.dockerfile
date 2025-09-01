# syntax=docker/dockerfile:1.4
FROM rust:latest

RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Rust tooling
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    rustup component add rustfmt clippy && \
    rustup target add wasm32-unknown-unknown && \
    rustup toolchain install nightly && \
    cargo install cargo-hack cargo-minimal-versions wasm-pack cargo-nextest

WORKDIR /workspace
COPY . .

# Build
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo build --workspace

# Split test suite with improved diagnostics
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    RUST_BACKTRACE=1 cargo test --workspace

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo nextest run --profile ci

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo hack check --feature-powerset -p tracing -p tracing-attributes -p tracing-appender

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo +nightly bench --workspace

# Windows cross-compilation
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    rustup target add x86_64-pc-windows-msvc && \
    cargo build --workspace --target x86_64-pc-windows-msvc

# Documentation generation
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    RUSTDOCFLAGS="-D warnings --cfg docsrs --cfg tracing_unstable" \
    RUSTFLAGS="--cfg tracing_unstable" \
    cargo +nightly doc --no-deps --all-features

# Linting and formatting
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo clippy --all --examples --tests --benches -- -D warnings

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    cargo fmt --all -- --check

# WASM tests
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=target \
    wasm-pack test --headless --chrome tracing

CMD ["/bin/bash"]