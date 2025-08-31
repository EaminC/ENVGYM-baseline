# CrossPrefetch Docker Environment
# Based on Ubuntu 18.04 (Bionic) as specified in the setvars.sh
FROM ubuntu:18.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install basic system packages and dependencies from install_packages.sh
RUN apt-get update && apt-get install -y \
    libncurses-dev \
    git \
    software-properties-common \
    python3-software-properties \
    python-software-properties \
    unzip \
    python-setuptools python-dev build-essential \
    python-pip \
    numactl \
    libnuma-dev \
    cmake \
    build-essential \
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
    sudo \
    wget \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install zplot psutil

# Create working directory
WORKDIR /crossprefetch

# Copy the entire repository
COPY . /crossprefetch/

# Set up environment variables from setvars.sh
ENV NVMBASE=/crossprefetch
ENV BASE=/crossprefetch
ENV PARA="-j$(nproc)"
ENV VER="5.14.0"
ENV KERN_SRC=/crossprefetch/linux-5.14.0
ENV SHELL=/bin/bash
ENV QEMU_IMG=/crossprefetch
ENV QEMU_IMG_FILE=/crossprefetch/qemu-image-fresh.img
ENV MOUNT_DIR=/crossprefetch/mountdir
ENV QEMUMEM="40"
ENV KERNEL=/crossprefetch/KERNEL
ENV MACHINE_NAME="ASPLOS"
ENV OUTPUT_FOLDER=/crossprefetch/results/ASPLOS/CAMERA-OPT-FINAL-TEST
ENV OUTPUT_GRAPH_FOLDER=/crossprefetch/results/ASPLOS/CAMERA-OPT-FINAL-TEST
ENV OUTPUTDIR=/crossprefetch/results/ASPLOS/CAMERA-OPT-FINAL-TEST
ENV LINUX_SCALE_BENCH=/crossprefetch/linux-scalability-benchmark
ENV APPBENCH=/crossprefetch/appbench
ENV APPS=/crossprefetch/appbench/apps
ENV SHARED_LIBS=/crossprefetch/shared_libs
ENV PREDICT_LIB_DIR=/crossprefetch/shared_libs/simple_prefetcher
ENV QUARTZ=/crossprefetch/shared_libs/quartz
ENV SCRIPTS=/crossprefetch/scripts
ENV UTILS=/crossprefetch/utils
ENV RUN_SCRIPTS=/crossprefetch/scripts/run
ENV QUARTZSCRIPTS=/crossprefetch/shared_libs/quartz/scripts
ENV SHARED_DATA=/crossprefetch/dataset
ENV APPPREFIX="/usr/bin/time -v"
ENV TEST_TMPDIR=/mnt/pmemdir

# Create necessary directories
RUN mkdir -p $KERNEL $OUTPUT_FOLDER $SHARED_DATA /mnt/pmemdir

# Compile the user-level library
RUN cd $PREDICT_LIB_DIR && ./compile.sh || true

# Set the default command to bash
CMD ["/bin/bash"]