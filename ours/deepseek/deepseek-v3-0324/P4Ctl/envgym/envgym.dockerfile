FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    bison \
    flex \
    make \
    g++ \
    libfl-dev \
    nmap \
    wget \
    git \
    build-essential \
    linux-headers-generic \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install scapy==2.4.5

WORKDIR /home/cc/P4Ctl
COPY . .

WORKDIR /home/cc/P4Ctl/compiler
RUN make netcl

WORKDIR /home/cc/P4Ctl
CMD ["/bin/bash"]