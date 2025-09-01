# Dockerfile for Acto development environment
FROM python:3.12-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /acto

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir \
    -r requirements.txt \
    -r requirements-dev.txt

# Set up the environment
ENV PYTHONPATH=/acto

# Default command
CMD ["/bin/bash"]