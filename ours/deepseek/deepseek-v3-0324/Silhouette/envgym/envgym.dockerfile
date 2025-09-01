FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/cc
ENV SILHOUETTE_DIR=$HOME/Silhouette

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    python3-dev \
    python3-setuptools \
    wget \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main" > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main" >> /etc/apt/sources.list.d/llvm.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    llvm-15 \
    clang-15 \
    llvm-15-dev \
    libclang-15-dev \
    clang-tools-15 \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    virt-manager \
    memcached \
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
    make \
    gcc \
    g++ \
    md5deep \
    linux-headers-generic \
    ssh \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    pymemcache \
    python-memcached \
    psutil \
    pytz \
    qemu.qmp \
    intervaltree \
    aenum \
    netifaces \
    prettytable \
    tqdm \
    numpy \
    matplotlib

RUN useradd -m -d $HOME -s /bin/bash cc && \
    mkdir -p $SILHOUETTE_DIR && \
    mkdir -p /mnt/ramdisk && \
    chown -R cc:cc $HOME

USER cc
WORKDIR $SILHOUETTE_DIR

RUN git clone https://github.com/iaoing/Silhouette.git . && \
    mkdir -p $SILHOUETTE_DIR/qemu_imgs && \
    wget -P $SILHOUETTE_DIR/qemu_imgs https://zenodo.org/records/14550794/files/silhouette_guest_vm.qcow2

WORKDIR $SILHOUETTE_DIR
RUN bash ./install_dep.sh

WORKDIR $SILHOUETTE_DIR/trace/build-llvm15
RUN make -j2 VERBOSE=1 || echo "Build may have warnings but continuing..."

WORKDIR $SILHOUETTE_DIR/codebase/scripts/fs_conf/sshkey
RUN chmod 600 fast25_ae_vm && \
    chmod 644 fast25_ae_vm.pub

WORKDIR $SILHOUETTE_DIR
CMD ["/bin/bash"]