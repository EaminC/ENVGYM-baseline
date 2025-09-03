FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV WORK_DIR=/home/cc/EnvGym/data/ELECT

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    git \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${WORK_DIR}

COPY . .

RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

CMD ["/bin/bash"]