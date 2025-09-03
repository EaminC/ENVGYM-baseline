FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.82.0
ENV RUST_NIGHTLY_VERSION=nightly-2025-01-25
ENV RUST_MIRI_NIGHTLY_VERSION=nightly-2025-06-02

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    jq \
    grep \
    sed \
    cpio \
    xz-utils \
    busybox-static \
    libssl-dev \
    libelf-dev \
    bison \
    flex \
    valgrind \
    llvm \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    liburing-dev \
    hunspell \
    hunspell-en-us \
    qemu-system-x86 \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUST_VERSION

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup toolchain install $RUST_VERSION && \
    rustup toolchain install $RUST_NIGHTLY_VERSION && \
    rustup toolchain install $RUST_MIRI_NIGHTLY_VERSION && \
    rustup component add rustfmt --toolchain $RUST_VERSION && \
    rustup component add clippy --toolchain $RUST_VERSION && \
    rustup component add rust-src --toolchain $RUST_VERSION && \
    rustup component add rust-src --toolchain $RUST_NIGHTLY_VERSION && \
    rustup component add miri --toolchain $RUST_MIRI_NIGHTLY_VERSION && \
    rustup target add x86_64-unknown-linux-musl --toolchain $RUST_VERSION && \
    rustup target add i686-unknown-linux-gnu --toolchain $RUST_VERSION && \
    rustup target add wasm32-unknown-unknown --toolchain $RUST_VERSION && \
    rustup target add wasm32-wasi --toolchain $RUST_VERSION

RUN cargo install cargo-edit || true && \
    cargo install cargo-watch || true && \
    cargo install cargo-spellcheck || true && \
    cargo install cargo-deny || true && \
    cargo install cross || true && \
    cargo install cargo-workspaces || true && \
    cargo install cargo-audit || true && \
    cargo install cargo-tarpaulin || true && \
    cargo install cargo-nextest || true && \
    cargo install cargo-hack || true && \
    cargo install cargo-semver-checks || true && \
    cargo install cargo-fuzz || true && \
    cargo install cargo-check-external-types || true && \
    cargo install cargo-docs-rs || true && \
    cargo install wasm-pack || true && \
    cargo install wasmtime-cli || true && \
    cargo install wasm-bindgen-cli || true && \
    cargo install act || true

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . .

CMD ["/bin/bash"]