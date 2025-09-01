FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ca-certificates \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /json

# Copy the entire repository
COPY . /json

# Optional: Install optional dependencies for testing or development
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set up build directory
RUN mkdir -p build && \
    cd build && \
    cmake .. && \
    make install

# Optional: Run tests if you want to verify the installation
RUN if [ -d "tests" ]; then \
    cd build && \
    ctest --output-on-failure; \
    fi

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]