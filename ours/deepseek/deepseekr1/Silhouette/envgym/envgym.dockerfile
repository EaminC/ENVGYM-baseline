FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    python3.10 \
    python3.10-venv \
    llvm-15 \
    clang-15 \
    libmemcached-dev \
    cmake \
    linux-headers-generic \
    llvm-15-tools \
    qemu-system-x86 \
    memcached \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash cc
USER cc
WORKDIR /home/cc
RUN mkdir -p EnvGym/data/Silhouette/qemu_imgs

RUN git clone https://github.com/iaoing/Silhouette.git EnvGym/data/Silhouette/Silhouette

RUN wget -O EnvGym/data/Silhouette/qemu_imgs/silhouette_guest_vm.qcow2 \
    https://zenodo.org/records/14550794/files/silhouette_guest_vm.qcow2

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette
RUN python3.10 -m venv venv

RUN . venv/bin/activate && \
    bash install_dep.sh && \
    bash prepare.sh && \
    ls -la codebase/tools && \
    ls -la codebase/tools/md5

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette/codebase/tools
RUN echo "=== Verifying md5 directory ===" && \
    pwd && ls -la md5/ && \
    cd md5 && \
    make clean && \
    make

RUN cd md5 && \
    [ -f ./md5 ] && \
    chmod +x md5 && \
    echo "=== Testing md5 binary ===" && \
    ACTUAL_HASH=$(printf "test" | ./md5 | head -c 32) && \
    echo "Expected: 098f6bcd4621d373cade4e832627b4f6" && \
    echo "Actual: '$ACTUAL_HASH'" && \
    [ "$ACTUAL_HASH" = "098f6bcd4621d373cade4e832627b4f6" ]

RUN cd src_info && make
RUN cd struct_layout_ast && make
RUN cd struct_layout_pass && make

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette/codebase/trace/build-llvm15
RUN . ../../../venv/bin/activate && make

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette/codebase/workload/ace
RUN . ../../../venv/bin/activate && \
    for i in 1 2 3; do \
        python ace.py -t pm -l $i && \
        python3 cmAdapterParallelSilhouette.py --i seq$i -n 8 && \
        make SEQ_DIR=seq$i OUT_DIR=bin -j8; \
    done

RUN qemu-img create -f qcow2 \
    -b /home/cc/EnvGym/data/Silhouette/qemu_imgs/silhouette_guest_vm.qcow2 \
    /home/cc/EnvGym/data/Silhouette/qemu_imgs/snapshot.qcow2

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette/codebase/scripts/fs_conf/sshkey
RUN chmod 600 fast25_ae_vm && chmod 644 fast25_ae_vm.pub

WORKDIR /home/cc/EnvGym/data/Silhouette/Silhouette
RUN echo "source /home/cc/EnvGym/data/Silhouette/Silhouette/venv/bin/activate" >> ~/.bashrc
CMD ["/bin/bash", "-i"]