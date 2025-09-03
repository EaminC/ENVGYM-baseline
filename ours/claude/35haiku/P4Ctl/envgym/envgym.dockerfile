FROM python:3.9-slim-bullseye AS base
LABEL maintainer="EnvGym Development Team"

ARG DEBIAN_FRONTEND=noninteractive
ARG SDE_VERSION=9.7.0

# System preparation
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    software-properties-common \
    bison \
    flex \
    ncat \
    make \
    gcc \
    libbpf-dev \
    libelf-dev \
    libz-dev

# Python dependencies
RUN pip install --no-cache-dir \
    scapy==2.4.5 \
    bcc

# Set working directory
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/P4Ctl

# Copy project files instead of cloning
COPY . .

# Set environment variables
ENV SDE=/opt/tofino
ENV SDE_INSTALL=/opt/tofino/install

# Compile compiler dependencies
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/P4Ctl/compiler
RUN make

# Return to project root
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/P4Ctl

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]