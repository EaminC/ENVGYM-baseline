FROM ubuntu:22.04 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV HOME=/root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    build-essential \
    python2.7 \
    python2.7-dev \
    python-pip \
    python-setuptools \
    bc \
    openjdk-8-jdk \
    locales

# Set locale
RUN locale-gen en_US.UTF-8

# Install pip for Python 2.7
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2.7 get-pip.py

# Install Python 2.7 specific libraries
RUN python2.7 -m pip install --no-cache-dir \
    six \
    astunparse \
    antlr4-python2-runtime \
    pystan==2.19.0 \
    pandas \
    edward \
    tensorflow==1.5.0

# Install PyTorch 0.4.0 (CPU version)
RUN python2.7 -m pip install https://download.pytorch.org/whl/cpu/torch-0.4.0-cp27-cp27mu-linux_x86_64.whl

# Install Pyro 0.2.1
RUN python2.7 -m pip install pyro-ppl==0.2.1

# Install ANTLR4
RUN apt-get update && apt-get install -y antlr4

# Create working directory
RUN mkdir -p /probfuzz
WORKDIR /probfuzz

# Copy project files
COPY . .

# Install project dependencies
RUN python2.7 -m pip install -r requirements.txt || true

# Default command
CMD ["/bin/bash"]