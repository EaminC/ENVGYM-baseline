FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.7 \
    python3-pip \
    python3-dev \
    git \
    wget \
    build-essential \
    flex \
    bison \
    libelf-dev \
    libssl-dev \
    libbpf-dev \
    clang \
    llvm \
    gcc-multilib \
    linux-headers-generic \
    netcat \
    iproute2 \
    net-tools \
    iputils-ping \
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install \
    scapy==2.4.5 \
    grpcio \
    grpcio-tools \
    ipaddress

# Install BCC (BPF Compiler Collection)
RUN git clone https://github.com/iovisor/bcc.git /tmp/bcc && \
    cd /tmp/bcc && \
    git checkout v0.24.0 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/bcc

# Install Python BCC bindings
RUN pip3 install bcc==0.24.0

# Set working directory
WORKDIR /P4Ctl

# Copy the repository contents
COPY . /P4Ctl/

# Build the NetCL compiler
RUN cd /P4Ctl/compiler && \
    make clean && \
    make

# Create symbolic link for netcl-compile in root directory
RUN ln -s /P4Ctl/compiler/netcl-compile /P4Ctl/netcl-compile

# Set up environment variables for potential Tofino integration
ENV SDE=/opt/bf-sde-9.7.0
ENV SDE_INSTALL=/opt/bf-sde-9.7.0/install
ENV PATH="${PATH}:/P4Ctl/compiler"

# Set Python path to include the project directory
ENV PYTHONPATH="/P4Ctl:${PYTHONPATH}"

# Default command - start bash shell
CMD ["/bin/bash"]