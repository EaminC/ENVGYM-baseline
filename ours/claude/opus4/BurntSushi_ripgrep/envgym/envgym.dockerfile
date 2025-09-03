FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.88.0
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=/usr/local/cargo/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gcc \
    g++ \
    clang \
    pkg-config \
    libpcre2-dev \
    libpcre2-8-0 \
    libpcre3 \
    libpcre3-dev \
    musl-tools \
    musl-dev \
    libjemalloc-dev \
    python3 \
    python3-pip \
    make \
    automake \
    autoconf \
    libtool \
    libtool-bin \
    autotools-dev \
    autogen \
    autoconf-archive \
    bc \
    binutils \
    unzip \
    poppler-utils \
    file \
    gzip \
    bzip2 \
    xz-utils \
    lz4 \
    brotli \
    zstd \
    sed \
    findutils \
    man-db \
    asciidoctor \
    ncompress \
    fish \
    zsh \
    bash \
    gnupg \
    coreutils \
    qemu-user \
    qemu-system \
    docker.io \
    tar \
    zlib1g-dev \
    liblzma-dev \
    libbz2-dev \
    liblz4-dev \
    golang-go \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} \
    && rustup component add rustfmt \
    && rustup target add i686-unknown-linux-gnu \
    && rustup target add x86_64-unknown-linux-musl \
    && rustup target add wasm32-wasip1 \
    && rustup toolchain install nightly \
    && rustup toolchain install beta

RUN cargo install --locked cargo-deb || true
RUN cargo install --locked cross --version 0.2.5 || true

RUN curl -L https://github.com/cli/cli/releases/download/v2.40.0/gh_2.40.0_linux_amd64.deb -o gh.deb \
    && dpkg -i gh.deb \
    && rm gh.deb

RUN apt-get update && apt-get install -y p7zip-full && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace/

RUN cargo build --release

RUN ./target/release/rg --version

WORKDIR /workspace
CMD ["/bin/bash"]