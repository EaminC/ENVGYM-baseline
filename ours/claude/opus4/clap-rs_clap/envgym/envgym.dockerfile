FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.89.0
ENV NODE_VERSION=20.x
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=/usr/local/cargo/bin:$PATH

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    make \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    fish \
    zsh \
    bash \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} --profile minimal

RUN . $CARGO_HOME/env && rustup component add rustfmt clippy rust-src

RUN . $CARGO_HOME/env && rustup target add wasm32-unknown-unknown wasm32-wasip2

RUN . $CARGO_HOME/env && rustup toolchain install nightly

RUN . $CARGO_HOME/env && cargo install cargo-edit \
    && cargo install cargo-tarpaulin \
    && cargo install cargo-release \
    && cargo install cargo-workspaces \
    && cargo install cargo-deny \
    && cargo install cargo-xtask \
    && cargo install typos-cli \
    && cargo install committed

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs \
    && npm install -g renovate

RUN pip3 install pre-commit

RUN curl -L https://dl.elv.sh/linux-amd64/elvish-v0.20.1.tar.gz -o elvish-v0.20.1.tar.gz \
    && mkdir -p /tmp/elvish-extract \
    && tar -xzf elvish-v0.20.1.tar.gz -C /tmp/elvish-extract \
    && find /tmp/elvish-extract -name "elvish*" -type f -executable -exec mv {} /usr/local/bin/elvish \; \
    && chmod +x /usr/local/bin/elvish \
    && rm -rf elvish-v0.20.1.tar.gz /tmp/elvish-extract

RUN wget https://github.com/nushell/nushell/releases/download/0.99.1/nu-0.99.1-x86_64-unknown-linux-gnu.tar.gz \
    && tar -xzf nu-0.99.1-x86_64-unknown-linux-gnu.tar.gz \
    && mv nu-0.99.1-x86_64-unknown-linux-gnu/nu /usr/local/bin/ \
    && rm -rf nu-0.99.1-x86_64-unknown-linux-gnu*

WORKDIR /home/cc/EnvGym/data/clap-rs_clap

COPY . .

RUN . $CARGO_HOME/env && cargo build --all

CMD ["/bin/bash"]