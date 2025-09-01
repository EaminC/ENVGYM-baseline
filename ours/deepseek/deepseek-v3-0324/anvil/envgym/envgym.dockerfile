FROM ubuntu:20.04

ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive
ENV VERUS_VERSION=3b6b805ac86cd6640d59468341055c7fa14cff07
ENV RUST_VERSION=1.88.0
ENV GO_VERSION=1.20
ENV KIND_VERSION=0.23.0
ENV DOCKER_VERSION=28.1.1

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    jq \
    openssl \
    gcc \
    ca-certificates \
    clang \
    libclang-dev \
    cmake \
    llvm \
    z3 \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install tabulate

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup component add rust-src rustfmt clippy && \
    rustup target add x86_64-unknown-linux-gnu && \
    rustc --version && \
    cargo --version

RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /root
RUN git clone https://github.com/verus-lang/verus.git --depth 1
WORKDIR /root/verus
RUN git fetch --tags
RUN git checkout ${VERUS_VERSION}
WORKDIR /root/verus/source
RUN cargo update --verbose && \
    cargo build --release --verbose --locked
RUN cp target/release/verus /usr/local/bin

WORKDIR /workspace
COPY . .

RUN chmod +x /workspace/scripts/*.sh

RUN curl -fsSL https://get.docker.com | sh
RUN usermod -aG docker root

CMD ["/bin/bash"]