FROM ubuntu:20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-dev \
        bison flex g++ make clang llvm libbcc-dev \
        libelf-dev zlib1g-dev libmnl-dev \
        git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and setuptools for PyPI src compatibility
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install Python dependencies
RUN pip3 install bcc scapy pyroute2

# Add repo contents to container
WORKDIR /P4Ctl
COPY . /P4Ctl

# Ensure scripts are executable
RUN chmod +x custom-send.py custom-recieve.py compiler/netcl-compile || true

# Entrypoint: interactive bash at repo root
ENTRYPOINT ["/bin/bash"]
