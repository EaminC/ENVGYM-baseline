FROM rust:1.61.0

RUN rustup install 1.56.0 && \
    rustup install 1.60.0 && \
    rustup install stable && \
    rustup install beta && \
    rustup install nightly-2025-05-16 && \
    rustup component add rust-src && \
    rustup component add clippy && \
    rustup component add miri --toolchain nightly-2025-05-16

WORKDIR /serde-rs_serde

COPY Cargo.toml .
COPY serde serde
COPY serde_derive serde_derive
COPY serde_derive_internals serde_derive_internals
COPY test_suite test_suite
COPY CONTRIBUTING.md .
COPY crates-io.md .
COPY LICENSE-APACHE .
COPY LICENSE-MIT .
COPY README.md .

RUN cargo fetch

RUN cargo build --workspace --all-features --verbose

CMD ["/bin/bash"]