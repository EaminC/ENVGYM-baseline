FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    software-properties-common

# Set working directory
WORKDIR /catch2

# Copy the entire repository
COPY . .

# Configure and build the project
RUN mkdir build && \
    cd build && \
    cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCATCH_BUILD_TESTING=OFF \
    -DCATCH_BUILD_EXAMPLES=OFF && \
    make install

# Set the default command to bash
CMD ["/bin/bash"]