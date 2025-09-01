FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    git \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    python3-pip \
    qemu-system-x86 \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install \
    pymemcache \
    memcache \
    psutil \
    pytz \
    qemu.qmp \
    intervaltree \
    aenum \
    netifaces \
    prettytable \
    tqdm \
    numpy \
    matplotlib

# Set working directory
WORKDIR /app

# Copy the entire repository
COPY . .

# Set permissions for SSH keys (if needed)
RUN chmod 600 codebase/scripts/fs_conf/sshkey/fast25_ae_vm && \
    chmod 644 codebase/scripts/fs_conf/sshkey/fast25_ae_vm.pub

# Prepare the tools
RUN cd codebase/tools/disk_content && make

# Default command to start bash
CMD ["/bin/bash"]