FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/cc \
    ANVIL_DIR=/home/cc/EnvGym/data/anvil \
    Z3_EXE=/usr/local/bin/z3 \
    PATH="${HOME}/.cargo/bin:${PATH}"

RUN useradd -m cc && \
    mkdir -p /home/cc/EnvGym/data/anvil && \
    chown -R cc:cc /home/cc

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    docker.io \
    golang-go \
    curl \
    git \
    libgmp-dev \
    re2c \
    libomp-dev \
    && rm -rf /var/lib/apt/lists/*

USER cc
WORKDIR /home/cc

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none && \
    . "$HOME/.cargo/env" && \
    rustup toolchain install nightly && \
    rustup toolchain install 1.88.0 && \
    rustup default 1.88.0

USER root
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN set -x && \
    git clone https://github.com/Z3Prover/z3 && \
    cd z3 && \
    git checkout z3-4.12.2 && \
    python scripts/mk_make.py --parallel=2 && \
    cd build && \
    make -j2 VERBOSE=1 && \
    make install
RUN cd / && rm -rf /home/cc/z3
USER cc

COPY --chown=cc:cc . ${ANVIL_DIR}
WORKDIR ${ANVIL_DIR}

RUN cargo update --workspace && \
    cargo build --workspace --release --jobs $(nproc) && \
    cargo test --workspace --features "openssl-tls kubederive ws runtime" --jobs $(nproc)

WORKDIR ${ANVIL_DIR}
CMD ["/bin/bash"]