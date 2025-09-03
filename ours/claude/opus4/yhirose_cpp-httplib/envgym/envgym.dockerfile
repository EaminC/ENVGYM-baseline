FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-9 \
    g++-9 \
    make \
    cmake \
    ninja-build \
    git \
    python3 \
    python3-pip \
    pkg-config \
    wget \
    curl \
    gnupg \
    lsb-release \
    libssl-dev \
    zlib1g-dev \
    libbrotli-dev \
    libzstd-dev \
    libcurl4-openssl-dev \
    libgtest-dev \
    squid \
    apache2-utils \
    netcat-openbsd \
    abigail-tools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main" >> /etc/apt/sources.list && \
    echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-18 main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y clang-16 clang-format-18 || \
    (apt-get install -y clang-16 && apt-get install -y clang-format) && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-12 g++-12 gcc-13 g++-13 libstdc++-13-dev || \
    (add-apt-repository -y ppa:ubuntu-toolchain-r/ppa && \
     apt-get update && \
     apt-get install -y gcc-12 g++-12 || true) && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    pre-commit>=3.0 \
    meson>=0.63.0

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 130 --slave /usr/bin/g++ g++ /usr/bin/g++-13 || \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 120 --slave /usr/bin/g++ g++ /usr/bin/g++-12 || \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-16 160 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-16 || true

RUN if command -v clang-format-18 >/dev/null 2>&1; then \
        update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-18 180; \
    elif command -v clang-format >/dev/null 2>&1; then \
        update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format 100; \
    fi

WORKDIR /workspace

COPY . /workspace/cpp-httplib/

WORKDIR /workspace/cpp-httplib

RUN if [ -f httplib.h ]; then \
        echo "httplib.h found"; \
    else \
        echo "Error: httplib.h not found" && exit 1; \
    fi

RUN mkdir -p build && \
    cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DHTTPLIB_REQUIRE_OPENSSL=ON \
        -DHTTPLIB_REQUIRE_ZLIB=ON \
        -DHTTPLIB_REQUIRE_BROTLI=ON \
        -DHTTPLIB_TEST=ON \
        -DHTTPLIB_COMPILE=OFF \
        -GNinja && \
    ninja || true

RUN cd /usr/src/gtest && \
    cmake . && \
    make && \
    cp lib/*.a /usr/lib/

RUN pre-commit install || true

RUN if [ -f test/proxy/basic_passwd ] && [ -f test/proxy/digest_passwd ]; then \
        echo "Proxy password files exist"; \
    else \
        mkdir -p test/proxy && \
        htpasswd -bc test/proxy/basic_passwd test test && \
        printf "test:cpp-httplib proxy:test\n" | htdigest -c test/proxy/digest_passwd; \
    fi

ENV CXX=g++-13
ENV CC=gcc-13
ENV CXXFLAGS="-std=c++23"

WORKDIR /workspace/cpp-httplib

CMD ["/bin/bash"]