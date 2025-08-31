# --- Silhouette env Dockerfile ---
FROM ubuntu:22.04

# Let apt work noninteractively
ENV DEBIAN_FRONTEND=noninteractive

# Install build essentials, python, and repo deps
RUN apt update && \
    apt-get -y install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    python3.10 python3.10-venv python3.10-dev python3-pip qemu-system-x86 memcached \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory for the repo
WORKDIR /Silhouette

# Copy all repo contents
COPY . /Silhouette

# Install Python packages required by Silhouette
RUN python3.10 -m pip install --upgrade pip && \
    python3.10 -m pip install pymemcache memcache psutil pytz qemu.qmp intervaltree aenum netifaces prettytable tqdm numpy matplotlib

# Setup repo, disable auto-memcached, and build disk_content
RUN bash ./prepare.sh

# Build C++ tool artifacts for disk_content
RUN make -C codebase/tools/disk_content

# Default to interactive Bash at repo root
CMD ["/bin/bash"]
