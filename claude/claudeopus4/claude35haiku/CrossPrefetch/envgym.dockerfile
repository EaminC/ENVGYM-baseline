FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    wget \
    software-properties-common \
    python3-software-properties \
    python-software-properties \
    unzip \
    python3-dev \
    python3-pip \
    build-essential \
    cmake \
    libncurses-dev \
    numactl \
    libnuma-dev \
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

# Install Python dependencies
RUN pip3 install zplot psutil

# Create a non-root user
RUN useradd -m -s /bin/bash crossuser && \
    echo "crossuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/crossuser/crossprefetch

# Copy the entire repository
COPY . .

# Change ownership
RUN chown -R crossuser:crossuser /home/crossuser/crossprefetch

# Switch to non-root user
USER crossuser

# Set environment variables
ENV BASE=/home/crossuser/crossprefetch

# Default command
CMD ["/bin/bash"]