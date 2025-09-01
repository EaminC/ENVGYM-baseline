# Stage 1: Build fuse-t from source
# Use a standard Ubuntu 20.04 base image compatible with x86_64 architecture.
FROM ubuntu:20.04 AS builder

# Set non-interactive frontend for package installation to prevent prompts.
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary build and runtime dependencies in a single layer
# and clean up apt caches to reduce layer size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libfuse-dev \
    pkg-config \
    uuid-dev \
    libgtest-dev \
    libcurl4 \
    libssl1.1 \
    libfuse2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory for the repository.
WORKDIR /app

# Clone the source code into the working directory.
RUN git clone https://github.com/s3fs-fuse/fuse-t.git .

# Check out a specific, stable version of the software.
RUN git checkout tags/v2022.04.02

# Create a dedicated build directory.
RUN mkdir build
WORKDIR /app/build

# Configure, build, and install the application.
# Use -j$(nproc) to leverage multiple CPU cores for a faster parallel build.
RUN cmake .. && \
    make -j$(nproc) && \
    make install

# Set the final working directory to the root of the repository.
WORKDIR /app

# Set the default command to a bash shell for an interactive CLI environment.
CMD ["/bin/bash"]