FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Install build dependencies and common tools
RUN apt-get update \
 && apt-get install -y \
      build-essential \
      autoconf \
      libtool \
      git \
      vim \
      less \
      curl \
      ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the entire repository
COPY . /app

# Build jq
RUN autoreconf -i \
 && ./configure \
      --disable-docs \
      --with-oniguruma=builtin \
      --enable-static \
      --enable-all-static \
      --prefix=/usr/local \
 && make -j$(nproc) \
 && make check VERBOSE=yes \
 && make install-strip

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]