# syntax = docker/dockerfile:1.4

FROM python:3.8-slim-bullseye AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libopenmpi-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir --jobs $(nproc) -r requirements.txt

FROM python:3.8-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libopenmpi3 \
    zlib1g \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=builder /app /app

WORKDIR /app
ENV PYTHONPATH=/app
CMD ["/bin/bash"]