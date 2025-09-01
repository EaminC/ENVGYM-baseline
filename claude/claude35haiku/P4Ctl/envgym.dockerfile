FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    git \
    bison \
    flex \
    gcc \
    g++ \
    cmake \
    make \
    libscapy-dev \
    ncat \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install scapy==2.4.5

# Set working directory
WORKDIR /repo

# Copy the entire repository
COPY . /repo

# Set up environment
RUN chmod +x *.sh

# Default command to start bash
CMD ["/bin/bash"]