# Stage 1: Base image with common dependencies and project source
FROM ubuntu:22.04 AS base

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install common system dependencies, build tools, and Python 3.7
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Prerequisites for adding repositories and general networking
    software-properties-common \
    ca-certificates \
    gnupg \
    # Version control and networking tools
    git \
    curl \
    nmap \
    iproute2 \
    # Build essentials and compiler tools
    build-essential \
    bison \
    flex \
    libfl-dev \
    # Add PPA, update, then install Python
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.7 \
        python3.7-distutils \
        python3.7-dev \
    # Clean up APT cache to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.7
RUN curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && \
    python3.7 get-pip.py && \
    rm get-pip.py

# Install required Python libraries
RUN python3.7 -m pip install --no-cache-dir scapy==2.4.5

# Set the working directory
WORKDIR /app

# Copy the project source code into the image
COPY . .

# Build the netcl policy compiler
RUN cd compiler && make netcl

# Stage 2: Switch image prepared for Tofino SDE
FROM base AS switch

# Set environment variables for Tofino SDE for consistency with the plan
ENV SDE=/root/bf-sde-9.7.0
ENV SDE_INSTALL=${SDE}/install
ENV PATH=${SDE_INSTALL}/bin:${PATH}
ENV LD_LIBRARY_PATH=${SDE_INSTALL}/lib:${LD_LIBRARY_PATH}

# --- Tofino SDE Installation Placeholder ---
# The Tofino SDE is proprietary and must be obtained from Intel.
# It is assumed to be present in the build context if needed.
# To install, place the SDE archive in the project root and uncomment the following:
#
# COPY bf-sde-9.7.0.tar.gz /root/
# RUN cd /root && \
#     tar -xf bf-sde-9.7.0.tar.gz && \
#     rm bf-sde-9.7.0.tar.gz && \
#     cd ${SDE} && \
#     ./p4studio_build/p4studio_build.py --use-profile p416_examples.pro

# Set the working directory to the root of the repository
WORKDIR /app

# Start a bash shell when the container is run
CMD ["/bin/bash"]

# Stage 3: Host image with eBPF/BCC tools (Default Target)
FROM base AS host

# Install eBPF/BCC tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bpfcc-tools \
    libbpfcc-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory to the root of the repository
WORKDIR /app

# Start a bash shell when the container is run
CMD ["/bin/bash"]