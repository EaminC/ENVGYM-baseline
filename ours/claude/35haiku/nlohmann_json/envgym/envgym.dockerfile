FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM=linux/amd64

# Base system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    software-properties-common \
    pkg-config \
    valgrind \
    clang \
    gcc-9 \
    g++-9 \
    libstdc++-9-dev \
    python3-pip \
    ninja-build

# Install Bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/6.0.0/bazel-6.0.0-linux-x86_64 -O /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel

# Install Meson
RUN pip3 install meson

# Install nlohmann/json
RUN git clone https://github.com/nlohmann/json.git /opt/nlohmann_json \
    && cd /opt/nlohmann_json \
    && cmake -B build -S . -DJSON_BuildTests=OFF \
    && cmake --install build

# Set working directory
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/nlohmann_json

# Set compiler versions
ENV CC=gcc-9
ENV CXX=g++-9

# Optimization flags
ENV CFLAGS="-march=native -O3"
ENV CXXFLAGS="-march=native -O3"

# Entrypoint
CMD ["/bin/bash"]