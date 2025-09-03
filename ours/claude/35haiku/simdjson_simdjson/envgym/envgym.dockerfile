FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
    software-properties-common \
    python3 \
    python3-pip \
    doxygen \
    ninja-build \
    valgrind \
    linux-tools-generic \
    libcurl4-openssl-dev \
    zlib1g-dev

# Install GCC and Clang
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y \
    gcc-11 \
    g++-11 \
    clang-12

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Docker CE
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# JSON Libraries
RUN apt-get install -y \
    libjson-c-dev \
    rapidjson-dev

# Google Benchmark
RUN git clone https://github.com/google/benchmark.git /tmp/benchmark && \
    cd /tmp/benchmark && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBENCHMARK_ENABLE_TESTING=OFF . && \
    make -j$(nproc) && \
    make install

# Set working directory
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/simdjson_simdjson

# Clone and prepare repository
RUN git clone https://github.com/simdjson/simdjson.git . && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-march=native -O3" . && \
    make -j$(nproc)

# Final stage
FROM base

ENTRYPOINT ["/bin/bash"]