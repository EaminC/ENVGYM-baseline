FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    python3 \
    python3-pip \
    qemu-user-static \
    qemu-system-arm \
    binfmt-support \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=tonistiigi/binfmt:latest /usr/bin/qemu-* /usr/bin/
RUN update-binfmts --enable

RUN curl -fsSL https://get.docker.com | sh

RUN mkdir -p /etc/docker && \
    echo '{"features":{"buildkit":true}}' > /etc/docker/daemon.json

WORKDIR /repo
COPY . .

RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && \
    if [ -f setup.py ]; then pip install -e .; fi

WORKDIR /repo
ENTRYPOINT ["/bin/bash"]