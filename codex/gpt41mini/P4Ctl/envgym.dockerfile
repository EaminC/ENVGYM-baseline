FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    python3.7 python3-pip python3-setuptools python3-dev build-essential \
    bison flex libelf-dev linux-headers-$(uname -r) \
    iproute2 net-tools iputils-ping \
    gcc clang llvm libclang-dev cmake wget curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Set python3 alternatives to python3.7 explicitly
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

# Upgrade pip and install python packages
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install scapy grpcio protobuf

# Set Tofino SDE environment variables
ENV SDE=/root/bf-sde-9.7.0/
ENV SDE_INSTALL=/root/bf-sde-9.7.0/install

# Workdir and copy repo
WORKDIR /app
COPY . /app

# Default to bash interactive shell
CMD ["/bin/bash"]
