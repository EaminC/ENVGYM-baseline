FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    meson \
    python3 \
    python3-pip \
    git \
    wget \
    ca-certificates \
    libssl-dev \
    libz-dev \
    libbrotli-dev \
    libzstd-dev \
    libcurl4-openssl-dev \
    pkg-config \
    clang-format \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /cpp-httplib

COPY . .

RUN mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native" \
          -DCMAKE_EXE_LINKER_FLAGS="-flto" \
          .. && \
    make -j$(nproc) && \
    find . -type f -executable

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libssl3 \
    libz1 \
    libbrotli1 \
    libzstd1 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /cpp-httplib

COPY --from=builder /cpp-httplib/build /cpp-httplib/build
COPY . .

CMD ["/bin/bash"]