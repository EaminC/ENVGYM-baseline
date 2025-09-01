FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    clang \
    clang-tidy \
    clang-format \
    lldb \
    git \
    wget \
    python3 \
    python3-pip \
    python3-setuptools \
    libc++-dev \
    libc++abi-dev \
    ninja-build \
    pkg-config \
    curl \
    unzip \
    libpthread-stubs0-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip && \
    pip3 install conan

WORKDIR /root
RUN git clone https://github.com/nlohmann/json.git && \
    cd json && \
    git checkout v3.12.0

WORKDIR /root/json
RUN mkdir -p tests/thirdparty/Fuzzer && \
    mkdir -p tests/corpus_json && \
    mkdir -p tests/corpus_bjdata && \
    mkdir -p tests/corpus_bson && \
    mkdir -p tests/corpus_cbor && \
    mkdir -p tests/corpus_msgpack && \
    mkdir -p tests/corpus_ubjson && \
    mkdir -p tests/thirdparty/doctest && \
    mkdir -p tests/thirdparty/fifo_map

RUN wget https://raw.githubusercontent.com/llvm/llvm-project/main/compiler-rt/lib/fuzzer/README.txt -P tests/thirdparty/Fuzzer && \
    wget https://raw.githubusercontent.com/doctest/doctest/v2.4.9/doctest/doctest.h -P tests/thirdparty/doctest && \
    wget https://raw.githubusercontent.com/nlohmann/fifo_map/master/src/fifo_map.hpp -P tests/thirdparty/fifo_map

RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64 -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

WORKDIR /root/json
RUN cmake -B build -DJSON_BuildTests=ON -DCMAKE_CXX_STANDARD=20 && \
    cmake --build build -j$(nproc)

WORKDIR /root/json/build
RUN ctest --output-on-failure

WORKDIR /root/json
CMD ["/bin/bash"]