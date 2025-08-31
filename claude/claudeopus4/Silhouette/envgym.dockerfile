FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install system dependencies
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
    memcached \
    make \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
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

# Create a non-root user for running the application
RUN useradd -m -s /bin/bash silhouette && \
    echo "silhouette ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/silhouette/Silhouette

# Copy the repository contents
COPY --chown=silhouette:silhouette . .

# Ensure scripts are executable
RUN chmod +x *.sh && \
    find . -name "*.sh" -type f -exec chmod +x {} \;

# Run prepare script (without starting services)
USER silhouette
RUN cd /home/silhouette/Silhouette && \
    sudo systemctl disable memcached 2>/dev/null || true && \
    cd codebase/scripts/fs_conf/sshkey && \
    chmod 600 fast25_ae_vm && \
    chmod 644 fast25_ae_vm.pub && \
    cd /home/silhouette/Silhouette/codebase/tools/disk_content && \
    make

# Set the default command to bash
CMD ["/bin/bash"]