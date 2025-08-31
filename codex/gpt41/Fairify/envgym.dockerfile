FROM ubuntu:20.04

# Prevent tzdata interaction
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages, Python 3.8, and pip
RUN apt-get update && \
    apt-get install -y python3.8 python3-pip python3-venv bash git && \
    rm -rf /var/lib/apt/lists/*

# Copy repo contents
WORKDIR /Fairify
COPY . /Fairify

# Install Python requirements
RUN python3.8 -m pip install --upgrade pip && \
    python3.8 -m pip install -r requirements.txt

# Default: interactive bash at repo root
ENTRYPOINT ["/bin/bash"]
