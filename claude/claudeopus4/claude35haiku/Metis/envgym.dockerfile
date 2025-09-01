FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc \
    g++ \
    git \
    libssl-dev \
    libxxhash-dev \
    libz-dev \
    libpthread-stubs0-dev \
    libprofiler-dev \
    make \
    python3 \
    python3-pip \
    sudo

# Set working directory
WORKDIR /metis

# Copy the entire repository
COPY . .

# Build the project
RUN make libmcfs

# Set default command to bash
CMD ["/bin/bash"]