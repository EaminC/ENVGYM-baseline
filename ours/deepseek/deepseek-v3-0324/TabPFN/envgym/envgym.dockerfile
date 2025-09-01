FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy local repository contents
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -e .

# Set up environment variables
ENV TABPFN_MODEL_CACHE_DIR=/app/data/TabPFN/models
ENV TABPFN_ALLOW_CPU_LARGE_DATASET=false
ENV TABPFN_EXCLUDE_DEVICES=mps
ENV FORCE_CONSISTENCY_TESTS=0

# Create necessary directories
RUN mkdir -p /app/data/TabPFN/models
RUN mkdir -p /app/tests/reference_predictions

WORKDIR /app

CMD ["/bin/bash"]