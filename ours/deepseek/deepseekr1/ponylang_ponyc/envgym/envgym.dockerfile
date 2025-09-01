FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        zlib1g-dev \
        libssl-dev \
        libpcre2-dev \
        libicu-dev \
        libedit-dev \
        wget \
        ca-certificates && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 16 && \
    apt-get remove -y wget ca-certificates && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm llvm.sh

# Set LLVM environment variables
ENV PATH="/usr/lib/llvm-16/bin:$PATH"
ENV LLVM_CONFIG="/usr/lib/llvm-16/bin/llvm-config"
ENV CC=clang-16
ENV CXX=clang++-16

# Build and install ponyc
RUN git clone https://github.com/ponylang/ponyc.git /ponyc && \
    cd /ponyc && \
    git submodule update --init --recursive lib/blake2 && \
    make -j$(nproc) config=release && \
    make install

WORKDIR /ponyc
ENTRYPOINT ["/bin/bash"]