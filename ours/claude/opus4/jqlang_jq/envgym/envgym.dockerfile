FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gcc \
    g++ \
    clang \
    libtool \
    make \
    automake \
    autoconf \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    flex \
    bison \
    byacc \
    binutils \
    pkg-config \
    python3.8 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    libonig-dev \
    valgrind \
    curl \
    tar \
    coreutils \
    findutils \
    diffutils \
    sed \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    gdb \
    clang-tools \
    dos2unix \
    rpm \
    xz-utils \
    tcl \
    gnupg \
    file \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip && \
    pip3 install pipenv virtualenv

WORKDIR /home/cc/EnvGym/data/jqlang_jq

RUN git clone https://github.com/jqlang/jq.git . && \
    git submodule update --init --recursive

RUN autoreconf -fi && \
    ./configure --with-oniguruma=builtin && \
    make -j$(nproc) && \
    make install

WORKDIR /home/cc/EnvGym/data/jqlang_jq

CMD ["/bin/bash"]