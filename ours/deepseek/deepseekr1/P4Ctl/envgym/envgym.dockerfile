FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /home/cc/EnvGym/data/P4Ctl

RUN apt-get update && \
    apt-get install -y \
    python3.7 \
    bison=2:3.5.1+dfsg-1 \
    flex=2.6.4-6.2 \
    libfl-dev=2.6.4-6.2 \
    python3-scapy \
    ncat \
    build-essential \
    linux-headers-5.15.0-91-generic \
    git \
    cmake \
    libedit-dev \
    llvm-12-dev \
    libclang-12-dev \
    zlib1g-dev \
    libelf-dev \
    wget \
    ca-certificates \
    bpfcc-tools

COPY . .

ARG SDE_URL
RUN set -eux; \
    if [ -f "bf-sde-9.7.0.tgz" ]; then \
        echo "Using local SDE tarball"; \
        cp bf-sde-9.7.0.tgz /tmp/bf-sde-9.7.0.tgz; \
    elif [ -z "${SDE_URL:-}" ]; then \
        echo "ERROR: Either place bf-sde-9.7.0.tgz in project root or provide SDE_URL" >&2; \
        exit 1; \
    else \
        wget -v -O /tmp/bf-sde-9.7.0.tgz "$SDE_URL" || { echo "wget failed with status $?" >&2; exit 1; }; \
    fi; \
    echo "Verifying tarball exists..."; \
    test -f /tmp/bf-sde-9.7.0.tgz || { echo "SDE tarball missing" >&2; exit 1; }; \
    echo "Extracting tarball..."; \
    mkdir -p /home/cc/bf-sde-9.7.0; \
    tar xvf /tmp/bf-sde-9.7.0.tgz -C /home/cc/bf-sde-9.7.0 --strip-components=1 || { echo "tar extraction failed" >&2; exit 1; }; \
    echo "Cleaning up..."; \
    rm -f /tmp/bf-sde-9.7.0.tgz

ENV SDE=/home/cc/bf-sde-9.7.0
ENV SDE_INSTALL=$SDE/install

RUN cd compiler && make clean && make netcl

RUN bash -c "source $SDE/set_sde.sh && $SDE/p4_build.sh -p switch/p4control.p4"

CMD ["/bin/bash"]