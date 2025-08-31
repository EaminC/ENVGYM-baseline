FROM ubuntu:20.04

# Prevent TZ prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and libraries
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       g++ \
       make \
       python3 \
       python3-pip \
       ca-certificates \
       git \
       curl \
       pkg-config \
       libssl-dev \
       zlib1g-dev \
       libbrotli-dev \
       libzstd-dev \
    && rm -rf /var/lib/apt/lists/*

# Set workdir to repo root
WORKDIR /repo

# Copy whole repo into container
COPY . /repo

# Default shell
CMD ["/bin/bash"]
