FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.10

RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3-venv \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir \
    pip

RUN pip install --no-cache-dir \
    pre-commit==2.21.0 \
    ruff==0.3.7 \
    mypy==1.9.0 \
    pytest \
    black \
    mkdocs \
    onnx

RUN pip install -e .

SHELL ["/bin/bash", "-c"]

CMD ["/bin/bash"]