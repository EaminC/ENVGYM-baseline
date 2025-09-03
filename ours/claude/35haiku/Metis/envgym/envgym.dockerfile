FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y \
    build-essential \
    cmake \
    gcc-11 \
    g++-11 \
    make \
    python3 \
    python3-pip \
    git \
    libfuse-dev \
    libnfs-dev \
    libattr1-dev \
    libacl1-dev \
    libcap-dev \
    libaio-dev \
    librdmacm-dev \
    libssl-dev \
    zlib1g-dev \
    libboost-all-dev \
    clang \
    llvm \
    libtool \
    autoconf \
    automake \
    pkg-config

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

RUN pip3 install --no-cache-dir \
    numpy \
    scipy \
    matplotlib \
    virtualenv \
    pulp

FROM ubuntu:22.04

COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/lib /usr/lib

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    libfuse2 \
    libssl3 \
    libboost-all-dev \
    cmake \
    build-essential \
    gcc \
    g++

WORKDIR /workspace
COPY . /workspace

RUN cd /workspace && \
    make VERBOSE=1 2>&1 | tee make_output.log && \
    cat make_output.log

ENTRYPOINT ["/bin/bash"]