FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    libssl-dev \
    pkg-config \
    openssl \
    ca-certificates \
    clang \
    libclang-dev \
    libgmp-dev \
    libgmp10 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install tabulate

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup toolchain install 1.88.0 && \
    rustup toolchain install nightly-2024-05-01 && \
    rustup default 1.88.0 && \
    rustup component add rustfmt rust-src rust-std --toolchain 1.88.0-x86_64-unknown-linux-gnu && \
    rustup component add rust-src rust-std --toolchain nightly-2024-05-01-x86_64-unknown-linux-gnu

RUN rustup show

RUN wget -O go.tar.gz https://go.dev/dl/go1.20.14.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

RUN go install sigs.k8s.io/kind@v0.23.0
ENV PATH="/root/go/bin:${PATH}"

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    install minikube-linux-amd64 /usr/local/bin/minikube && \
    rm minikube-linux-amd64

WORKDIR /anvil

RUN git clone https://github.com/verus-lang/verus.git /tmp/verus || (echo "Failed to clone Verus repository" && exit 1)

RUN cd /tmp/verus && git checkout 3b6b805ac86cd6640d59468341055c7fa14cff07

RUN wget https://github.com/Z3Prover/z3/releases/download/z3-4.12.5/z3-4.12.5-x64-glibc-2.31.zip -O /tmp/z3.zip && \
    unzip /tmp/z3.zip -d /tmp/ && \
    mv /tmp/z3-4.12.5-x64-glibc-2.31 /tmp/verus/z3 && \
    rm /tmp/z3.zip

ENV VERUS_Z3_PATH="/tmp/verus/z3"
ENV Z3_EXE="/tmp/verus/z3/bin/z3"
ENV RUST_TOOLCHAIN="nightly-2024-05-01"
ENV RUSTUP_TOOLCHAIN="nightly-2024-05-01"

RUN cd /tmp/verus/source && \
    rustup override set nightly-2024-05-01 && \
    export RUST_SRC_PATH="$(rustc +nightly-2024-05-01 --print sysroot)/lib/rustlib/src/rust/library" && \
    RUST_BACKTRACE=full cargo +nightly-2024-05-01 build --release --features unstable --verbose 2>&1 || (echo "verus build failed with exit code $?" && exit 1)

RUN mkdir -p /anvil/verus && \
    cp -r /tmp/verus/* /anvil/verus/ && \
    rm -rf /tmp/verus

ENV VERUS_Z3_PATH="/anvil/verus/z3"
ENV Z3_EXE="/anvil/verus/z3/bin/z3"
ENV PATH="/anvil/verus/source/target-verus/release:${PATH}"
ENV RUST_TOOLCHAIN="1.88.0"
ENV RUSTUP_TOOLCHAIN="1.88.0"

COPY . /anvil/

RUN mkdir -p /anvil/.cargo && \
    echo '[build]\ntarget-dir = "/anvil/target"' > /anvil/.cargo/config.toml

RUN echo '#!/bin/bash\nsource /anvil/verus/source/tools/activate\nexec "$@"' > /anvil/tools/activate && \
    chmod +x /anvil/tools/activate

RUN mkdir -p /anvil/certs

ENV RUST_LOG=info
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup

WORKDIR /anvil

CMD ["/bin/bash"]