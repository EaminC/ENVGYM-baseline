FROM ubuntu:22.04

WORKDIR /repository

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    software-properties-common

COPY . /repository

RUN chmod +x /repository/*

ENTRYPOINT ["/bin/bash"]