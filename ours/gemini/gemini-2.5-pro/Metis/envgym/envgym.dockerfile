FROM --platform=linux/amd64 ubuntu:20.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Step 1: Install all system dependencies in a single layer for efficiency
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core Tools & Build Essentials
    git \
    vim \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    m4 \
    autoconf \
    bison \
    flex \
    # Python
    python3-pip \
    # Kernel & System Utilities
    sudo \
    linux-headers-generic \
    binutils \
    rename \
    mtd-utils \
    rpcbind \
    dbus \
    util-linux \
    lsof \
    openssh-client \
    # Filesystem Tools
    btrfs-progs \
    f2fs-tools \
    jfsutils \
    nilfs-tools \
    xfsprogs \
    # NFS Tools
    nfs-common \
    nfs-kernel-server \
    # MCFS & NFS-Ganesha Dependencies
    libssl-dev \
    libfuse-dev \
    google-perftools \
    libgoogle-perftools-dev \
    zlib1g-dev \
    libnfsidmap-dev \
    libtirpc-dev \
    libkrb5-3 \
    libkrb5-dev \
    libk5crypto3 \
    libgssapi-krb5-2 \
    libgssglue1 \
    libdbus-1-3 \
    libattr1-dev \
    libacl1-dev \
    libdbus-1-dev \
    libcap-dev \
    libjemalloc-dev \
    uuid-dev \
    libblkid-dev \
    xfslibs-dev \
    libwbclient-dev \
    rpm2cpio \
    libaio-dev \
    libibverbs-dev \
    librdmacm-dev \
    libboost-all-dev \
    liburcu-dev \
    libxxhash-dev \
    && rm -rf /var/lib/apt/lists/*

# Step 2: Install Python packages
RUN pip3 install --no-cache-dir numpy scipy matplotlib

# Step 3: Set the primary working directory and clone repositories
WORKDIR /home/cc/EnvGym/data
RUN git clone https://github.com/sbu-fsl/Metis.git
RUN git clone https://github.com/sbu-fsl/RefFS.git
RUN git clone https://github.com/sbu-fsl/IOCov.git

# Force git to use HTTPS instead of SSH for dependencies
RUN git config --global url."https://github.com/".insteadOf "git@github.com:"

# Step 4: Build and install dependencies using the project's script
# The following command is commented out for debugging purposes as it was the point of failure.
# RUN /home/cc/EnvGym/data/Metis/scripts/setup-deps.sh

# Step 5: Build the custom brd.ko kernel module
# Commented out as it depends on the previous step.
# WORKDIR /home/cc/EnvGym/data/Metis/kernel/brd-for-5.4.0
# RUN make

# Step 6: Build the main projects
# Commented out as they depend on previous steps.
# WORKDIR /home/cc/EnvGym/data/Metis
# RUN make && make install
# WORKDIR /home/cc/EnvGym/data/RefFS
# RUN make

# Step 7: Set the final working directory and default command for interactive debugging
WORKDIR /home/cc/EnvGym/data/Metis
CMD ["/bin/bash"]