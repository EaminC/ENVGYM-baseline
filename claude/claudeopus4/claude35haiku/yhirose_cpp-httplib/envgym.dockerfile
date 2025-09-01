FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    git \
    libssl-dev \
    ninja-build \
    python3 \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /cpp-httplib

# Copy the entire repository
COPY . .

# Optionally install additional dependencies if needed
RUN pip3 install meson

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]

# Default command will be an interactive shell
CMD ["-l"]