FROM ubuntu:20.04

# Prevent tzdata from asking for user input
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    cmake \
    git \
    libatomic1 \
    make \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /ponyc

# Copy the entire repository
COPY . .

# Initialize and update git submodules
RUN git submodule update --init --recursive

# Build LLVM libraries (this takes a while)
RUN make libs build_flags="-j$(nproc)"

# Configure the build
RUN make configure

# Build ponyc
RUN make build

# Install ponyc system-wide
RUN make install

# Clean up build artifacts to reduce image size
RUN make clean

# Set working directory back to repository root
WORKDIR /ponyc

# Default to bash shell
CMD ["/bin/bash"]