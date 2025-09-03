FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.7.16

RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    wget \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libsqlite3-dev \
    libreadline-dev \
    libffi-dev \
    curl \
    libbz2-dev \
    python3-pip \
    python3-venv

RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar -xf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --enable-optimizations \
    && make -j $(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}

RUN ln -sf /usr/local/bin/python3.7 /usr/bin/python3

FROM base AS builder

WORKDIR /app

COPY . .

RUN python3 -m pip install --upgrade pip \
    && python3 -m venv venv \
    && . venv/bin/activate \
    && pip install torch==1.13.1 --extra-index-url https://download.pytorch.org/whl/cpu \
    && pip install torchvision==0.14.1 --extra-index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt

FROM base

WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /app/venv /app/venv

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

CMD ["/bin/bash"]