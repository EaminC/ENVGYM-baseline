FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get clean

RUN apt-get install -y --fix-missing \
    build-essential \
    git \
    wget \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --fix-missing \
    python3 \
    python3-pip \
    python3-dev \
    clang \
    g++ \
    gcc \
    make \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --fix-missing \
    libssl-dev \
    libffi-dev \
    lsb-release \
    findutils \
    tar \
    ca-certificates \
    systemtap-sdt-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --fix-missing \
    netcat \
    imagemagick \
    libreadline-dev \
    libedit-dev \
    libncurses5-dev \
    tcpdump \
    net-tools \
    lsof \
    time \
    htop \
    sysstat \
    gnupg \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ focal main" && \
    apt-get update && \
    apt-get install -y cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" && \
    apt-get update && apt-get install -y --fix-missing \
    llvm-15 \
    llvm-15-dev \
    llvm-15-runtime \
    llvm-15-tools \
    clang-15 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-15 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    mkdocs \
    mkdocs-material \
    pyyaml \
    yamllint \
    pandas \
    matplotlib \
    jupyter

RUN npm install -g \
    markdownlint-cli \
    markdownlint-cli2

RUN wget https://github.com/rhysd/actionlint/releases/download/v1.6.26/actionlint_1.6.26_linux_amd64.tar.gz && \
    tar xzf actionlint_1.6.26_linux_amd64.tar.gz && \
    mv actionlint /usr/local/bin/ && \
    rm actionlint_1.6.26_linux_amd64.tar.gz

RUN mkdir -p /tmp/googletest && \
    cd /tmp/googletest && \
    wget https://github.com/google/googletest/archive/refs/tags/v1.17.0.tar.gz && \
    tar xzf v1.17.0.tar.gz && \
    cd googletest-1.17.0 && \
    cmake . && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/googletest

RUN mkdir -p /tmp/benchmark && \
    cd /tmp/benchmark && \
    wget https://github.com/google/benchmark/archive/v1.9.1.tar.gz && \
    tar xzf v1.9.1.tar.gz && \
    cd benchmark-1.9.1 && \
    cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release . && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/benchmark

WORKDIR /workspace

COPY . .

ENV CC=clang-15
ENV CXX=clang++-15

RUN ls -la && \
    test -f Makefile && \
    echo "Makefile found, proceeding with build..." || echo "Makefile not found!"

RUN make libs build_flags="-j$(nproc) VERBOSE=1" || (echo "make libs failed with exit code $?"; exit 1)

RUN make configure build_flags="-j$(nproc)" && \
    make build build_flags="-j$(nproc)" && \
    make install

ENV PATH=/usr/local/bin:$PATH

WORKDIR /workspace

CMD ["/bin/bash"]