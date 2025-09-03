FROM ubuntu:22.04 AS base

LABEL platform=linux/amd64

WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/CrossPrefetch

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN pip3 install --no-cache-dir -r requirements.txt

FROM ubuntu:22.04

WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/CrossPrefetch

COPY --from=base /home/cc/EnvGym/data-gpt-4.1mini/CrossPrefetch .

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=base /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages

ENTRYPOINT ["/bin/bash"]