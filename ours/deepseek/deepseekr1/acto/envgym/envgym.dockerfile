# Base image with Python 3.12
FROM python:3.12-slim-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    wget \
    ca-certificates \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://get.docker.com | sh

# Install Go 1.20.5
RUN curl -OL https://go.dev/dl/go1.20.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz && \
    rm go1.20.5.linux-amd64.tar.gz
ENV PATH="$PATH:/usr/local/go/bin"

# Install Kind
RUN go install sigs.k8s.io/kind@v0.20.0

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . .

# Create virtual environment
RUN python -m venv .venv
ENV PATH="/workspace/.venv/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install . && \
    pip install '.[dev]' && \
    pip install -r requirements-dev.txt

# Set up pre-commit
RUN pre-commit install

# Build libraries with parallel compilation
RUN make -j$(nproc) -C acto/k8s_util/lib && \
    make -j$(nproc) -C ssa

# Create profile directory
RUN mkdir -m 777 -p /home/cc/EnvGym/data/acto/profile/data

# Validate Python packages
RUN python -c "import pydantic, kubernetes, pandas, pytest, mypy, black, pylint, requests, docker, cryptography, pre_commit"

# Default command
CMD ["/bin/bash"]