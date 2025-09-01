FROM rust:1.57

WORKDIR /home/cc/EnvGym/data/tokio-rs_bytes

RUN rustup install nightly-2024-09-15 --profile minimal && \
    rustup default nightly-2024-09-15

RUN rustup component add rust-src --toolchain nightly-2024-09-15 && \
    rustup component add clippy --toolchain nightly-2024-09-15 && \
    rustup component add miri --toolchain nightly-2024-09-15 || true

RUN rustup target add x86_64-unknown-linux-gnu && \
    rustup default stable

RUN cargo install cargo-hack || \
    cargo install --git https://github.com/taiki-e/cargo-hack cargo-hack || true

COPY Cargo.toml .
COPY src/lib.rs src/lib.rs
COPY ci/test-stable.sh ci/test-stable.sh
COPY ci/panic-abort.sh ci/panic-abort.sh
COPY ci/tsan.sh ci/tsan.sh
COPY ci/miri.sh ci/miri.sh
COPY clippy.toml .

RUN mkdir -p .github/workflows && \
    chmod +x ci/*.sh

RUN cargo build || true
RUN cargo build --no-default-features || true
RUN cargo build --features serde || true
RUN cargo test || true

COPY . .

CMD ["/bin/bash"]