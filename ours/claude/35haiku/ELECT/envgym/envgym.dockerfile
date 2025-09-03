FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-pip

COPY . /app

RUN pip3 install -r requirements.txt

ENTRYPOINT ["/bin/bash"]