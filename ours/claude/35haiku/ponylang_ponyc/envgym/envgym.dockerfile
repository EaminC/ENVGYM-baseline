FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# Fundamental system preparation
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common wget curl git gpg ca-certificates

# Install core build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    gcc-11 \
    g++-11 \
    cmake \
    make \
    python3.10 \
    python3-pip \
    valgrind \
    gdb \
    lldb \
    binutils-gold \
    libatomic1 \
    libstdc++-11-dev \
    zlib1g-dev \
    linux-headers-generic \
    sudo \
    libssl-dev \
    llvm-dev \
    libncurses5-dev \
    libpcre2-dev \
    zlib1g-dev

# Set default compiler versions
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

# Install Pony dependencies
RUN mkdir -p /root/.local/share/ponyup/bin && \
    wget https://get.pony-lang.org/release/ponyup-init.sh -O /root/.local/share/ponyup/ponyup-init.sh && \
    chmod +x /root/.local/share/ponyup/ponyup-init.sh && \
    /root/.local/share/ponyup/ponyup-init.sh || true

# Set environment variables
ENV PATH="/root/.local/share/ponyup/bin:${PATH}"
ENV CC=clang
ENV CXX=clang++

WORKDIR /workspace

# Copy repository
COPY . /workspace

# Build Pony project with verbose output and continue on test failures
RUN make config=release VERBOSE=1 || true && \
    make test config=release VERBOSE=1 || true

FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libstdc++-11-dev \
    zlib1g-dev \
    libssl-dev

# Copy built artifacts from builder
COPY --from=builder /workspace /workspace

WORKDIR /workspace

CMD ["/bin/bash"]