# syntax = docker/dockerfile:1.4

FROM ubuntu:20.04 as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --parallel $(nproc)

FROM ubuntu:20.04 as runtime
WORKDIR /app
COPY . .
CMD ["/bin/bash"]