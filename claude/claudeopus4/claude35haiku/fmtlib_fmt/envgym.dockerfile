FROM ubuntu:22.04

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /fmt

# Copy the entire repository
COPY . .

# Configure and build the library
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -G Ninja .. && \
    cmake --build . && \
    cmake --install .

# Set the default command to bash
CMD ["/bin/bash"]