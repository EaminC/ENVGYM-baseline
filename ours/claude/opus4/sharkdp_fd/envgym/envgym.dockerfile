FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.77.2
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    git \
    curl \
    make \
    build-essential \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    jq \
    pkg-config \
    libssl-dev \
    ca-certificates \
    cmake \
    libclang-dev \
    clang \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh \
    && chmod +x rustup-init.sh \
    && ./rustup-init.sh -y --default-toolchain ${RUST_VERSION} \
    && rm rustup-init.sh

RUN . /root/.cargo/env \
    && rustup component add rustfmt clippy

RUN . /root/.cargo/env \
    && cargo install cross --locked --verbose || true

RUN . /root/.cargo/env \
    && cargo install cargo-audit || true

WORKDIR /workspace

COPY . /workspace/

RUN . /root/.cargo/env \
    && cargo build --release --locked

RUN . /root/.cargo/env \
    && make completions

RUN mkdir -p /root/.config/fd \
    && echo ".git/" > /root/.config/fd/ignore \
    && echo "*.bak" >> /root/.config/fd/ignore \
    && echo "/mnt/external-drive" >> /root/.config/fd/ignore

RUN echo 'export FZF_DEFAULT_COMMAND="fd --type f"' >> /root/.bashrc \
    && echo 'export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"' >> /root/.bashrc

WORKDIR /workspace

CMD ["/bin/bash"]