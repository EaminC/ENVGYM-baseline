FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
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
    git \
    wget \
    vim \
    sudo

# Create a non-root user
RUN useradd -m -s /bin/bash rfuse \
    && echo "rfuse ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the rfuse user
USER rfuse
WORKDIR /home/rfuse

# Clone the repository (you'll need to mount or copy the actual repo contents)
RUN git clone https://github.com/snu-csl/rfuse.git

# Set the working directory to the repository root
WORKDIR /home/rfuse/rfuse

# Default command to start a bash shell
CMD ["/bin/bash"]