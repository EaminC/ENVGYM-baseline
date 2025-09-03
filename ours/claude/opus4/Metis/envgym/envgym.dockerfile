FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    cmake \
    git \
    vim \
    m4 \
    autoconf \
    bison \
    flex \
    bc \
    kmod \
    cpio \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    libncurses5-dev \
    libelf-dev \
    libncurses-dev \
    libfuse-dev \
    libssl-dev \
    libcrypto++-dev \
    libgoogle-perftools-dev \
    libxxhash-dev \
    zlib1g-dev \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    libnfsidmap-dev \
    libtirpc-dev \
    libkrb5-dev \
    libgssglue1 \
    libdbus-1-3 \
    libattr1-dev \
    libacl1-dev \
    dbus \
    libdbus-1-dev \
    libcap-dev \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    libjemalloc-dev \
    uuid-dev \
    libblkid-dev \
    xfslibs-dev \
    libwbclient-dev \
    rpm2cpio \
    libaio-dev \
    libibverbs-dev \
    librdmacm-dev \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    rpcbind \
    nfs-common \
    libboost-all-dev \
    liburcu-dev \
    nilfs-tools \
    nfs-kernel-server \
    xfsprogs \
    f2fs-tools \
    jfsutils \
    btrfs-progs \
    mtd-utils \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    tmux \
    screen \
    fio \
    openssh-client \
    openssh-server \
    lcov \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    lttng-tools \
    liblttng-ust-dev \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    less \
    valgrind \
    gdb \
    wget \
    curl \
    python3 \
    python3-pip \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install numpy scipy matplotlib PuLP ply

WORKDIR /Metis

COPY . /Metis/

RUN ldconfig

CMD ["/bin/bash"]