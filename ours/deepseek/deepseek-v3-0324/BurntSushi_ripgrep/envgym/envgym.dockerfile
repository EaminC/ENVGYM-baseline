FROM ubuntu:22.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    build-essential \
    musl-tools \
    musl-dev \
    pkg-config \
    zlib1g-dev \
    liblzma-dev \
    xz-utils \
    liblz4-tool \
    brotli \
    zstd \
    make \
    gcc \
    diffutils \
    zsh \
    jq \
    wget \
    unzip \
    automake \
    autoconf \
    libtool \
    libpcre3-dev \
    libpcre2-dev \
    libpcre3 \
    pcre2-utils \
    libpcre++-dev \
    libpcre3-dbg \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.88.0
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup toolchain install beta
RUN rustup toolchain install nightly
RUN rustup target add x86_64-unknown-linux-musl
RUN rustup target add x86_64-pc-windows-gnu
RUN rustup target add x86_64-pc-windows-msvc

RUN cargo install cross --version 0.2.5
RUN cargo install cargo-deb
RUN cargo install ripgrep

RUN wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
    && tar xf ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz \
    && cp ripgrep-13.0.0-x86_64-unknown-linux-musl/rg /usr/local/bin/ \
    && rm -rf ripgrep-13.0.0*

RUN wget https://github.com/ggreer/the_silver_searcher/archive/2.2.0.tar.gz \
    && tar xzf 2.2.0.tar.gz \
    && cd the_silver_searcher-2.2.0 \
    && ./autogen.sh \
    && ./configure --disable-dependency-tracking \
    && make \
    && make install \
    && cd .. \
    && rm -rf the_silver_searcher-2.2.0 2.2.0.tar.gz || true

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

RUN mkdir -p /root/.config/ripgrep \
    && echo "--color=auto\n--hidden\n--follow" > /root/.config/ripgrep/ripgrep.conf \
    && touch /root/.ignore \
    && touch .rgignore

RUN mkdir -p .github/workflows \
    && mkdir -p deployment/deb \
    && mkdir -p deployment/m2/complete \
    && mkdir -p deployment/m2/doc \
    && mkdir -p crates/core/flags/complete \
    && mkdir -p ci \
    && mkdir -p /tmp/benchsuite \
    && mkdir -p benchsuite/runs \
    && mkdir -p .cargo

RUN touch .cargo/config.toml \
    && touch COPYING LICENSE-MIT UNLICENSE \
    && touch CHANGELOG.md README.md \
    && touch ci/ubuntu-install-packages \
    && touch ci/build-and-publish-m2 \
    && touch ci/test-complete \
    && touch crates/core/flags/complete/rg.zsh \
    && touch ci/utils.sh \
    && touch benchsuite/benchsuite \
    && touch benchsuite/runs/raw.csv

WORKDIR /root/ripgrep
CMD ["/bin/bash"]