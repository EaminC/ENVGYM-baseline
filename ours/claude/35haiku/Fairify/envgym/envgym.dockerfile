FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /fairify

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir tensorflow-cpu==2.13.0 && \
    pip install --no-cache-dir -r requirements.txt || \
    (echo "Error installing requirements" && cat requirements.txt)

COPY . .

RUN chmod +x src/fairify.sh

WORKDIR /fairify

CMD ["/bin/bash"]