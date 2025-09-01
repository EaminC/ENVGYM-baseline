FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /home/cc/EnvGym/data/Metis

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    python3.8 \
    python3-pip \
    libssl-dev \
    libfuse-dev \
    google-perftools \
    libnfsidmap-dev \
    libtirpc-dev \
    libkrb5-dev \
    libattr1-dev \
    libacl1-dev \
    libjemalloc-dev \
    uuid-dev \
    libblkid-dev \
    libboost-all-dev \
    liburcu-dev \
    libxxhash-dev \
    nilfs-tools \
    libjson-c-dev \
    mtd-utils \
    xfsprogs \
    rename \
    tmux \
    screen \
    sshpass \
    syslog-ng \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install numpy scipy matplotlib PuLP PLY

RUN git clone https://github.com/sbu-fsl/RefFS.git && \
    git clone https://github.com/sbu-fsl/IOCov.git && \
    git clone https://github.com/sbu-fsl/fsl-spin.git && \
    git clone https://github.com/sbu-fsl/swarm-mcfs.git && \
    git clone https://github.com/nfs-ganesha/nfs-ganesha.git && \
    git clone https://github.com/Cyan4973/xxHash.git --branch v0.8.0 && \
    git clone https://github.com/madler/zlib.git

RUN mkdir -p \
    /home/cc/EnvGym/data/Metis/fs-state \
    /home/cc/EnvGym/data/Metis/scripts/multi_machines_analysis \
    /home/cc/EnvGym/data/Metis/RefFS/build \
    /home/cc/EnvGym/data/Metis/nfs-ganesha/src/build \
    /home/cc/EnvGym/data/Metis/common \
    /home/cc/EnvGym/data/Metis/example \
    /home/cc/EnvGym/data/Metis/verifs1 \
    /home/cc/EnvGym/data/Metis/mcl-demo \
    /home/cc/EnvGym/data/Metis/python-demo/auto_ambiguity_detector/examples \
    /home/cc/EnvGym/data/Metis/python-demo/auto_ambiguity_detector/LP_demo \
    /mnt/test-ext4 \
    /mnt/test-ext2 \
    /mnt/test-jffs2 \
    /mnt/test-nfs-ganesha-export

RUN touch \
    /home/cc/EnvGym/data/Metis/.tmux.conf \
    /home/cc/EnvGym/data/Metis/fs-state/swarm.lib \
    /home/cc/EnvGym/data/Metis/fs-state/parameters.py \
    /home/cc/EnvGym/data/Metis/fs-state/replay.c \
    /home/cc/EnvGym/data/Metis/fs-state/sequence.log \
    /home/cc/EnvGym/data/Metis/fs-state/perf.csv \
    /home/cc/EnvGym/data/Metis/common/errnoname.c \
    /home/cc/EnvGym/data/Metis/common/nanotiming.c \
    /home/cc/EnvGym/data/Metis/example/test.c \
    /home/cc/EnvGym/data/Metis/example/Makefile \
    /home/cc/EnvGym/data/Metis/example/test.log

CMD ["/bin/bash"]