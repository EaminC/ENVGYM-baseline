# syntax=docker/dockerfile:1
FROM ubuntu:20.04

# Non-interactive is needed for apt in Docker.
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Python 3.8
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.8 \
        python3-pip \
        python3-setuptools \
        python3-dev \
        build-essential \
        git \
        ffmpeg \
        libgl1-mesa-dev \
        libsdl1.2-dev \
        libsdl2-dev \
        libopenmpi-dev \
        libasound2-dev \
        libfreetype6-dev \
        swig \
        curl \
        libsmpeg-dev \
        libportmidi-dev \
        libswscale-dev \
        libavformat-dev \
        libavcodec-dev \
        libsdl-image1.2-dev \
        libsdl-mixer1.2-dev \
        libsdl-ttf2.0-dev \
        libboost-all-dev \
        mesa-utils \
        xvfb \
        x11vnc \
        pkg-config \
        libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

# Upgrade pip, install requirements
RUN python3.8 -m pip install --upgrade pip
RUN python3.8 -m pip install --no-cache-dir -r requirements.txt

# Editable install for repo itself if needed
RUN python3.8 -m pip install --no-cache-dir -e ./tool/src

# Include coax.txt extra requirements if relevant
RUN if [ -f tool/scripts/extra_deps/coax.txt ]; then python3.8 -m pip install --no-cache-dir -r tool/scripts/extra_deps/coax.txt; fi

ENV PYTHONPATH=/workspace/tool/src

# Default to interactive shell at workspace root
CMD ["/bin/bash"]
