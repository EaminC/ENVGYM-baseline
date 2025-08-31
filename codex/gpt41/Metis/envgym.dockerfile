FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /repo

# Core system/deps
RUN apt-get update && apt-get install -y \
    build-essential gcc g++ cmake git vim \
    python3 python3-pip python3-setuptools python3-wheel \
    m4 autoconf bison flex make \
    libssl-dev libfuse-dev google-perftools libgoogle-perftools-dev \
    libnfsidmap-dev libtirpc-dev libkrb5-3 libkrb5-dev libk5crypto3 \
    libgssapi-krb5-2 libgssglue1 libdbus-1-3 libattr1-dev libacl1-dev dbus libdbus-1-dev \
    libcap-dev libjemalloc-dev uuid-dev libblkid-dev xfslibs-dev libwbclient-dev \
    rpm2cpio libaio-dev libibverbs-dev librdmacm-dev rpcbind nfs-common \
    libboost-all-dev liburcu-dev libxxhash-dev nilfs-tools rename mtd-utils \
    ca-certificates curl

# Python packages for demos/scripts
RUN pip3 install numpy scipy matplotlib pulp

# Copy source
COPY . /repo/

# Build core repo (library)
RUN make && make clean

# Set default shell and working dir
ENTRYPOINT ["/bin/bash"]
WORKDIR /repo
