FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    ninja-build \
    meson \
    pkg-config \
    autoconf \
    kernel-package \
    libncurses5-dev \
    bison \
    flex \
    libssl-dev \
    fio \
    python2 \
    libelf-dev \
    rsync \
    zstd \
    udev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /src

# Copy repo contents
COPY . /src

# Build rfuse kernel modules
RUN make -C driver

# Build user libraries with meson (lib/librfuse)
RUN cd lib/librfuse && meson setup builddir --buildtype=release && meson compile -C builddir && meson install -C builddir

# Build user filesystems examples
RUN make -C filesystems/nullfs
RUN make -C filesystems/stackfs

# Default CMD to bash
CMD ["/bin/bash"]
