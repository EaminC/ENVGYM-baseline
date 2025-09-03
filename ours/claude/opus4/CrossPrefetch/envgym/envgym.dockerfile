FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    software-properties-common \
    python3 \
    python3-pip \
    python3-dev \
    cmake \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/CrossPrefetch

RUN mkdir -p /home/cc/EnvGym/data/CrossPrefetch

CMD ["/bin/bash"]