FROM ubuntu:20.04

# Set noninteractive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    meson \
    ninja-build \
    pkg-config \
    autoconf \
    kernel-package \
    libncurses5-dev \
    bison \
    flex \
    libssl-dev \
    fio \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    libelf-dev \
    rsync \
    zstd \
    udev \
    libfuse3-dev \
    vim \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Python Sphinx dependencies (for docs, not required to run core)
RUN pip3 install sphinx==2.4.4 sphinx_rtd_theme

# Create a user to avoid root container
RUN useradd -m -s /bin/bash envgym && echo 'envgym ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER envgym
WORKDIR /home/envgym

# Copy and install repo
COPY . /home/envgym/rfuse
WORKDIR /home/envgym/rfuse

# Install libfuse and librfuse
RUN cd lib/libfuse && ./libfuse_install.sh && \
    cd ../../lib/librfuse && ./librfuse_install.sh

# Build NullFS and StackFS
RUN cd filesystems/nullfs && make && \
    cd ../stackfs && make

# Set default shell
CMD ["/bin/bash"]
