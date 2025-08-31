# Dockerfile for Lottery Ticket Hypothesis Research Environment
FROM python:3.7-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy requirements first for better caching
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire repository
COPY . .

# Create directories for storing results if they don't exist
RUN mkdir -p /workspace/results \
    && mkdir -p /workspace/plots \
    && mkdir -p /workspace/tensorboard_logs

# Set the working directory to the repository root
WORKDIR /workspace

# Default command: drop into bash shell
CMD ["/bin/bash"]