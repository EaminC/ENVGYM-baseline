FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install apt dependencies and Python 3.12
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        git \
        curl \
        wget \
        build-essential \
        ca-certificates \
        libssl-dev \
        libffi-dev \
        python3.12 \
        python3.12-venv \
        python3.12-dev \
        python3-pip \
        kubectl \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Use python3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install pip for python3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Copy repo contents
WORKDIR /repo
COPY . /repo

# Install Python requirements
RUN python3.12 -m pip install --upgrade pip \
    && python3.12 -m pip install --no-cache-dir -r requirements.txt \
    && python3.12 -m pip install --no-cache-dir -r requirements-dev.txt || true

# Install as editable for best import usability
RUN python3.12 -m pip install --no-cache-dir --editable .

# Set entry to bash shell at repo root
WORKDIR /repo
ENTRYPOINT ["/bin/bash"]
