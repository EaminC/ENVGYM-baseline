FROM ubuntu:22.04

# Avoid prompts from apt
ARG DEBIAN_FRONTEND=noninteractive

# Install OS dependencies
RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    python3-pip qemu-system-x86 memcached && \
    rm -rf /var/lib/apt/lists/*

# Install python packages
RUN pip3 install pymemcache memcache psutil pytz qemu.qmp intervaltree aenum netifaces prettytable tqdm numpy matplotlib

# Copy repo files into container
WORKDIR /Silhouette
COPY . /Silhouette

# Disable memcached auto start (optional, as in prepare.sh script)
RUN systemctl disable memcached || true

CMD ["/bin/bash"]
