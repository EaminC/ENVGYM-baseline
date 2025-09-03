FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN pip3 install jupyter matplotlib numpy pandas scipy scikit-learn

ENTRYPOINT ["/bin/bash"]