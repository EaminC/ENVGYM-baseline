FROM ubuntu:22.04

# Avoid interactive UI prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: git, cmake, g++ and make
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /repo

# Copy the entire repo into the container
COPY . /repo

# Build and install the project
RUN mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install

# Default working directory when container runs
WORKDIR /repo

# Run bash shell by default
CMD ["/bin/bash"]
