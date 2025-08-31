FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Install build dependencies and development tools
RUN apt-get update \
 && apt-get install -y \
      build-essential \
      autoconf \
      automake \
      libtool \
      git \
      bison \
      flex \
      valgrind \
      python3 \
      python3-pip \
      vim \
      nano \
      curl \
      wget \
      gdb \
      pkg-config \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /jq

# Copy the entire repository
COPY . /jq

# Initialize git submodules (for oniguruma)
RUN if [ -d ".git" ]; then \
      git submodule update --init; \
    fi

# Build jq
RUN autoreconf -i \
 && ./configure \
      --with-oniguruma=builtin \
      --enable-maintainer-mode \
      --prefix=/usr/local \
 && make -j$(nproc) \
 && make install

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Start in bash at the repository root
CMD ["/bin/bash"]