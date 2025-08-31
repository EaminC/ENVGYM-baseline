FROM ubuntu:22.04
LABEL maintainer="cc"
ENV DEBIAN_FRONTEND=noninteractive

# Install basics and build essentials
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    doxygen \
    wget \
    pkg-config \
    vim \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /repo

# Copy repo contents
COPY . /repo

# Build and install fmtlib (release mode)
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --target install -- -j$(nproc)

# Set entrypoint to /bin/bash and start at repo root
WORKDIR /repo
ENTRYPOINT ["/bin/bash"]
