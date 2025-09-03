FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /home/cc/EnvGym/data/rfuse

RUN mkdir -p /home/cc/EnvGym/data/rfuse/{src,data,models,logs}

COPY requirements.txt* ./

RUN pip3 install --no-cache-dir --upgrade pip && \
    if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

RUN apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . .

CMD ["/bin/bash"]