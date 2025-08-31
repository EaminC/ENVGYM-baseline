# TabPFN Dockerfile
# Base image with Python 3.11 for TabPFN compatibility
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    make \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /TabPFN

# Copy the entire repository
COPY . .

# Install pip and upgrade it
RUN python -m pip install --upgrade pip

# Install TabPFN in editable mode with dev dependencies
RUN pip install -e ".[dev]"

# Download all models for offline usage
RUN python scripts/download_all_models.py || echo "Model download script not found or failed - models will be downloaded on first use"

# Set environment variables for better PyTorch performance
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512

# Set default command to bash
CMD ["/bin/bash"]