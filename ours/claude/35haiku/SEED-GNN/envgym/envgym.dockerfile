FROM python:3.8-slim-bullseye AS builder

WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/SEED-GNN

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir \
    torch==2.0.0 --extra-index-url https://download.pytorch.org/whl/cpu \
    torch-geometric==2.3.1 \
    torchvision==0.15.1 --extra-index-url https://download.pytorch.org/whl/cpu \
    torchaudio==2.0.1 --extra-index-url https://download.pytorch.org/whl/cpu \
    numpy==1.24.4 \
    pandas==2.0.3 \
    scipy==1.10.1 \
    ogb==1.3.6

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x main.py

ENV PYTHONPATH=/home/cc/EnvGym/data-gpt-4.1mini/SEED-GNN

CMD ["/bin/bash"]