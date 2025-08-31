# Base image - Ubuntu 22.04 as mentioned in the documentation
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV BASEDIR=/home/mcfs
ENV MCFS_BUILD_TYPE=Debug

# Install basic packages and development tools
RUN apt-get update && apt-get install -y \
    # Basic tools and compilers
    gcc g++ git vim \
    build-essential m4 autoconf bison flex cmake make \
    # Dependencies for MCFS/Metis
    mtd-tools libssl-dev \
    libfuse-dev \
    google-perftools \
    libgoogle-perftools-dev \
    # Dependencies for nfs-ganesha
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
    dbus \
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
    rpcbind \
    nfs-common \
    libboost-all-dev \
    liburcu-dev \
    libxxhash-dev \
    nilfs-tools \
    rename \
    mtd-utils \
    # Python packages for IOCov
    python3-pip \
    # Additional utilities
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for IOCov
RUN pip3 install numpy scipy matplotlib

# Create working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/Metis/

# Set working directory to repository root
WORKDIR /workspace/Metis

# Build libmcfs
RUN make clean && make && make install

# Create user 'mcfs' to avoid running as root
RUN useradd -m -s /bin/bash mcfs && \
    echo 'mcfs ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to mcfs user
USER mcfs
WORKDIR /workspace/Metis

# Set default command to bash
CMD ["/bin/bash"]