FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies as per scripts/install_packages.sh
RUN apt-get update && apt-get install -y \
    libncurses-dev \
    git \
    software-properties-common \
    python3-software-properties \
    python-software-properties \
    unzip \
    python-setuptools \
    python-dev \
    build-essential \
    python-pip \
    numactl \
    libnuma-dev \
    cmake \
    libboost-dev \
    libboost-thread-dev \
    libboost-system-dev \
    libboost-program-options-dev \
    libconfig-dev \
    uthash-dev \
    cscope \
    msr-tools \
    msrtool \
    libmpich-dev \
    libzstd-dev \
    liblz4-dev \
    libsnappy-dev \
    libssl-dev \
    libgflags-dev \
    zlib1g-dev \
    libbz2-dev \
    libevent-dev \
    systemd \
    libaio-dev \
    libjemalloc-dev \
 && rm -rf /var/lib/apt/lists/*

# Install python packages
RUN pip install zplot psutil

# Set working directory to /workspace (repo root inside container)
WORKDIR /workspace

# Copy repo contents into container
COPY . /workspace

# Set necessary environment variables from scripts/setvars.sh
ENV NVMBASE=/workspace
ENV BASE=/workspace
ENV OS_RELEASE_NAME=bionic
ENV PARA=-j$(nproc)
ENV VER=5.14.0
ENV KERN_SRC=/workspace/linux-5.14.0
ENV SHELL=/bin/bash
ENV QEMU_IMG=/workspace
ENV QEMU_IMG_FILE=/workspace/qemu-image-fresh.img
ENV MOUNT_DIR=/workspace/mountdir
ENV QEMUMEM=40
ENV KERNEL=/workspace/KERNEL
ENV MACHINE_NAME=ASPLOS
ENV OUTPUT_FOLDER=/workspace/results/$MACHINE_NAME/CAMERA-OPT-FINAL-TEST
ENV OUTPUT_GRAPH_FOLDER=/workspace/results/$MACHINE_NAME/CAMERA-OPT-FINAL-TEST
ENV OUTPUTDIR=/workspace/results/$MACHINE_NAME/CAMERA-OPT-FINAL-TEST
ENV LINUX_SCALE_BENCH=/workspace/linux-scalability-benchmark
ENV APPBENCH=/workspace/appbench
ENV APPS=/workspace/appbench/apps
ENV SHARED_LIBS=/workspace/shared_libs
ENV PREDICT_LIB_DIR=/workspace/shared_libs/simple_prefetcher
ENV QUARTZ=/workspace/shared_libs/quartz

CMD ["/bin/bash"]
