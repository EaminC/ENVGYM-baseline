FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    g++-9 \
    g++-10 \
    g++-11 \
    g++-12 \
    gcc \
    gcc-9 \
    gcc-10 \
    gcc-11 \
    gcc-12 \
    cmake \
    make \
    ninja-build \
    pkg-config \
    git \
    wget \
    curl \
    python3 \
    python3-dev \
    python3-pip \
    doxygen \
    graphviz \
    valgrind \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    zlib1g \
    zlib1g-dev \
    libcurl4-openssl-dev \
    binutils \
    vim \
    subversion \
    unzip \
    zip \
    xz-utils \
    libc++-dev \
    libc++abi-dev \
    libstdc++6 \
    qemu-user \
    sed \
    diffutils \
    tar \
    gzip \
    file \
    grep \
    findutils \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    clang-13 \
    clang++-13 \
    clang-format-13 \
    clangd-13 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    clang-14 \
    clang++-14 \
    clang-format-14 \
    clangd-14 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/keyrings/llvm-archive-keyring.asc > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.asc] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" > /etc/apt/sources.list.d/llvm-16.list && \
    echo "deb-src [signed-by=/etc/apt/keyrings/llvm-archive-keyring.asc] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" >> /etc/apt/sources.list.d/llvm-16.list

RUN apt-get update && \
    apt-get install -y \
    clang-16 \
    clang++-16 \
    clang-format-16 \
    clangd-16 \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y \
    gcc-13 \
    g++-13 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

RUN git clone https://github.com/simdjson/simdjson.git /simdjson

WORKDIR /simdjson

RUN git clone https://github.com/bloomberg/clang-p2996.git /tmp/clang-p2996 && \
    cd /tmp/clang-p2996 && \
    git checkout p2996

RUN wget https://github.com/emscripten-core/emsdk/archive/refs/heads/main.zip -O /tmp/emsdk.zip && \
    unzip /tmp/emsdk.zip -d /opt && \
    mv /opt/emsdk-main /opt/emsdk && \
    cd /opt/emsdk && \
    ./emsdk install latest && \
    ./emsdk activate latest && \
    rm /tmp/emsdk.zip

ENV PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:${PATH}"

RUN mkdir -p /simdjson/build && \
    cd /simdjson/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -GNinja && \
    ninja

ENV CC=gcc
ENV CXX=g++
ENV CMAKE_PREFIX_PATH=/simdjson/build
ENV LD_LIBRARY_PATH=/simdjson/build:$LD_LIBRARY_PATH

WORKDIR /simdjson

CMD ["/bin/bash"]