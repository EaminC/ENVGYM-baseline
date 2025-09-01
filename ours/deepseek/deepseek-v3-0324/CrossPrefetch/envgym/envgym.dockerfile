FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    procps \
    htop \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p /app/data/input \
    /app/data/output \
    /app/data/models

COPY . .

VOLUME /app/data

CMD ["/bin/bash"]