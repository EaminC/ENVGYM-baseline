FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LLVM_SHA=3b5b5c1ec4a3095ab096dd780e84d7ab81f3d7ff
ENV LLVM_PATCH_SHA=b272d53fbbf35476362d21b0fd6141d50372f824ef5e3e02e13c83604538eaad
ENV REPO_DIR=/ponylang_ponyc

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    linux-headers-generic \
    libc6-dbg \
    libc6-dev \
    libstdc++6 \
    libatomic-ops-dev \
    libncurses5-dev \
    libssl-dev \
    netcat \
    wget \
    python3 \
    clang \
    llvm \
    libgoogle-gtest-dev \
    libbenchmark-dev \
    pkg-config \
    zlib1g-dev \
    gdb \
    strace \
    systemtap-sdt-dev \
    libpcre3-dev \
    libreadline-dev \
    libtool \
    libffi-dev \
    libunwind-dev \
    binutils-dev \
    libiberty-dev \
    systemtap \
    linux-tools-generic \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ponylang/ponyc.git ${REPO_DIR} \
    && cd ${REPO_DIR} \
    && git submodule update --init --recursive

WORKDIR ${REPO_DIR}

RUN cd ${REPO_DIR} \
    && git -C lib/llvm/src checkout ${LLVM_SHA} \
    && wget -O lib/llvm/patches/2025-04-30-gcc-15.diff "https://github.com/llvm/llvm-project/commit/${LLVM_PATCH_SHA}.diff" \
    && git -C lib/llvm/src apply ../lib/llvm/patches/2025-04-30-gcc-15.diff

RUN mkdir -p \
    test/full-program-runner \
    test/rt-stress/tcp-open-close

RUN touch \
    test/full-program-runner/CMakeLists.txt \
    test/libponyc/CMakeLists.txt \
    test/libponyrt/CMakeLists.txt \
    test/rt-stress/tcp-open-close/CMakeLists.txt

RUN make config=release prefix=/usr/local

CMD ["/bin/bash"]