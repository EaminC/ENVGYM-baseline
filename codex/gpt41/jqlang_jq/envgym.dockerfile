FROM ubuntu:20.04

# Avoid prompts in apt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        libtool \
        git \
        ca-certificates \
        pkg-config \
        flex \
        bison \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repo and set up build
WORKDIR /repo
COPY . /repo

# Build jq (recommended source install)
RUN git submodule update --init \
    && autoreconf -i \
    && ./configure --with-oniguruma=builtin \
    && make -j$(nproc) \
    && make check \
    && make install

# Entrypoint: bash
WORKDIR /repo
ENTRYPOINT ["/bin/bash"]
