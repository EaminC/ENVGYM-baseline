FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    libssl-dev \
    libcrypto++-dev \
    libpthread-stubs0-dev \
    libxxhash-dev \
    zlib1g-dev \
    libgoogle-perftools-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /Metis

COPY . /Metis

RUN make

CMD ["/bin/bash"]
