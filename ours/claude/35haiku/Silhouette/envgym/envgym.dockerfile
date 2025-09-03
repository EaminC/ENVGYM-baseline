FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git wget qemu-system-x86 \
    python3.10-dev python3-pip \
    llvm-15-dev clang-15 \
    libz-dev libncurses5-dev \
    libssl-dev zlib1g-dev \
    build-essential software-properties-common \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder

WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/Silhouette

COPY . .

RUN pip3 install --no-cache-dir \
    pymemcache memcache psutil \
    pytz qemu.qmp intervaltree \
    aenum netifaces prettytable \
    tqdm numpy matplotlib

RUN chmod +x *.sh

FROM base

COPY --from=builder /home/cc/EnvGym/data-gpt-4.1mini/Silhouette /home/cc/EnvGym/data-gpt-4.1mini/Silhouette
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/Silhouette

CMD ["/bin/bash"]