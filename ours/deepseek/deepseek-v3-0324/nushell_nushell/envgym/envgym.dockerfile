FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    git \
    openssl \
    libssl-dev \
    perl \
    sqlite3 \
    libsqlite3-dev \
    clang \
    dpkg \
    bash \
    coreutils \
    less \
    build-essential \
    pkg-config \
    cmake \
    && rm -rf /var/lib/apt/lists/*

ENV CARGO_HOME=/usr/local/cargo
ENV PATH=$CARGO_HOME/bin:$PATH
ENV RUSTUP_HOME=/usr/local/rustup
ENV RUST_VERSION=1.87.0

RUN wget https://sh.rustup.rs -O rustup-init.sh && \
    chmod +x rustup-init.sh && \
    ./rustup-init.sh -y --default-toolchain $RUST_VERSION && \
    rm rustup-init.sh && \
    chmod -R a+w $CARGO_HOME

RUN . $CARGO_HOME/env && \
    rustc --version && \
    cargo --version

WORKDIR /workspace
COPY . .

RUN mkdir -p /root/.config/nushell && \
    cp crates/nu-utils/src/default_files/default_env.nu /root/.config/nushell/env.nu && \
    cp crates/nu-utils/src/default_files/default_config.nu /root/.config/nushell/config.nu

RUN . $CARGO_HOME/env && \
    cargo build --release --locked

WORKDIR /workspace
CMD ["/bin/bash"]