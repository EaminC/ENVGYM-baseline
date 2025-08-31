FROM ubuntu:20.04

# Prevent interactive prompts during package installation
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
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /rfuse

# Copy the entire repository
COPY . .

# Set the number of CPU cores for RFUSE (48 cores as detected)
RUN sed -i 's/#define RFUSE_NUM_IQUEUE.*/#define RFUSE_NUM_IQUEUE 48/' lib/librfuse/include/rfuse.h && \
    sed -i 's/#define RFUSE_NUM_IQUEUE.*/#define RFUSE_NUM_IQUEUE 48/' driver/rfuse/rfuse.h

# Build librfuse
RUN cd lib/librfuse && \
    rm -rf build && \
    mkdir build && \
    cd build && \
    meson .. && \
    ninja && \
    ninja install

# Build libfuse (optional, but included for completeness)
RUN cd lib/libfuse && \
    rm -rf build && \
    mkdir build && \
    cd build && \
    meson .. && \
    ninja && \
    ninja install

# Build filesystems
RUN cd filesystems/nullfs && make
RUN cd filesystems/stackfs && make

# Set up library path
ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}

# Create a script to remind users about kernel module installation
RUN echo '#!/bin/bash' > /rfuse/setup_reminder.sh && \
    echo 'echo "=========================================="' >> /rfuse/setup_reminder.sh && \
    echo 'echo "RFUSE Container Setup Reminder:"' >> /rfuse/setup_reminder.sh && \
    echo 'echo ""' >> /rfuse/setup_reminder.sh && \
    echo 'echo "1. The kernel modules (rfuse/fuse) cannot be built inside the container."' >> /rfuse/setup_reminder.sh && \
    echo 'echo "   You need to build and install them on the host system."' >> /rfuse/setup_reminder.sh && \
    echo 'echo ""' >> /rfuse/setup_reminder.sh && \
    echo 'echo "2. To use RFUSE, you need:"' >> /rfuse/setup_reminder.sh && \
    echo 'echo "   - Linux kernel 5.15.0 installed on the host"' >> /rfuse/setup_reminder.sh && \
    echo 'echo "   - Build and insmod the rfuse kernel driver on the host"' >> /rfuse/setup_reminder.sh && \
    echo 'echo ""' >> /rfuse/setup_reminder.sh && \
    echo 'echo "3. Run the container with --privileged flag to access kernel modules"' >> /rfuse/setup_reminder.sh && \
    echo 'echo ""' >> /rfuse/setup_reminder.sh && \
    echo 'echo "4. The repository is installed at /rfuse"' >> /rfuse/setup_reminder.sh && \
    echo 'echo "=========================================="' >> /rfuse/setup_reminder.sh && \
    chmod +x /rfuse/setup_reminder.sh

# Set the default command to run bash and show the reminder
CMD ["/bin/bash", "-c", "/rfuse/setup_reminder.sh && exec /bin/bash"]