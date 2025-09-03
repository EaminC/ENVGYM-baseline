FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    software-properties-common \
    build-essential \
    nodejs \
    npm

WORKDIR /repository

COPY . .

RUN npm install

ENTRYPOINT ["/bin/bash"]