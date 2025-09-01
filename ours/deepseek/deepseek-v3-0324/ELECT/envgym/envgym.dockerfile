# Use the specified base image for AMD64 architecture
FROM ubuntu:20.04

# Set environment variables
ENV ELECT_NO_GPU=1
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKDIR=/home/cc/EnvGym/data/ELECT

# Create working directory structure
RUN mkdir -p /home/cc/EnvGym/data
WORKDIR $WORKDIR

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone repository (adjust as needed)
# COPY . $WORKDIR
# OR
# RUN git clone <repository_url> $WORKDIR

# Install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Set default command
CMD ["/bin/bash"]