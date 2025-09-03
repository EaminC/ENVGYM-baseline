FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.87.0
ENV CARGO_HOME=/home/cc/.cargo
ENV RUSTUP_HOME=/home/cc/.rustup
ENV PATH=/home/cc/.cargo/bin:$PATH

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    perl \
    clang \
    libsqlite3-dev \
    libgit2-dev \
    libgtk-3-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libwayland-dev \
    curl \
    wget \
    git \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    wine64 \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash cc && \
    usermod -aG sudo,docker cc && \
    echo 'cc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER cc
WORKDIR /home/cc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none && \
    . $CARGO_HOME/env && \
    rustup toolchain install $RUST_VERSION && \
    rustup default $RUST_VERSION && \
    rustup component add rustfmt clippy rust-docs && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add aarch64-unknown-linux-musl && \
    rustup target add x86_64-pc-windows-gnu

RUN . $CARGO_HOME/env && \
    cargo install cross --git https://github.com/cross-rs/cross --locked || true

RUN . $CARGO_HOME/env && \
    cargo install cargo-binstall --locked || true

RUN . $CARGO_HOME/env && \
    cargo install cargo-audit --locked || true

RUN . $CARGO_HOME/env && \
    cargo install cargo-outdated --locked || true

RUN for i in 1 2 3; do \
        wget -qO- https://github.com/rui314/mold/releases/download/v2.4.0/mold-2.4.0-$(uname -m)-linux.tar.gz | tar xz && \
        sudo mv mold*/bin/mold /usr/local/bin/ && \
        sudo chmod +x /usr/local/bin/mold && \
        rm -rf mold* && \
        break || \
        if [ $i -eq 3 ]; then echo "Mold installation failed after 3 attempts, continuing without it"; fi; \
        sleep 5; \
    done

RUN mkdir -p /home/cc/nushell_nushell
WORKDIR /home/cc/nushell_nushell

COPY --chown=cc:cc . .

RUN . $CARGO_HOME/env && \
    cargo build --release --locked

RUN . $CARGO_HOME/env && \
    cargo build --release --features full --locked || true

RUN . $CARGO_HOME/env && \
    cargo build --release --no-default-features --locked || true

RUN . $CARGO_HOME/env && \
    cargo build --release --features static-link-openssl --locked || true

RUN mkdir -p /home/cc/.config/nushell && \
    ./target/release/nu -c "exit" || true

RUN mkdir -p /home/cc/.cargo && \
    if [ -f /usr/local/bin/mold ]; then \
        echo '[target.x86_64-unknown-linux-gnu]\nlinker = "clang"\nrustflags = ["-C", "link-arg=-fuse-ld=/usr/local/bin/mold"]' > /home/cc/.cargo/config.toml; \
    else \
        echo '[target.x86_64-unknown-linux-gnu]\nlinker = "clang"' > /home/cc/.cargo/config.toml; \
    fi

RUN echo "/home/cc/.cargo/bin/nu" | sudo tee -a /etc/shells

ENV RUST_BACKTRACE=1
ENV CARGO_INCREMENTAL=1
ENV PATH=/home/cc/nushell_nushell/target/release:$PATH

WORKDIR /home/cc/nushell_nushell

CMD ["/bin/bash"]