FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for building simdjson
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    wget \
    curl \
    ca-certificates \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /simdjson

# Copy the entire repository into the container
COPY . /simdjson

# Prepare build directory
RUN mkdir -p /simdjson/build

# Configure and build the project
RUN cd /simdjson/build && \
    cmake -DSIMDJSON_DEVELOPER_MODE=ON -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc)

# Set the default command to launch a bash shell
CMD ["/bin/bash"]