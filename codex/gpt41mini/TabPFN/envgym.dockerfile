FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system packages for build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy entire repo
COPY . /app

# Upgrade pip and install the package in editable mode with dev extras
RUN pip install --upgrade pip && \
    pip install -e .[dev]

# Default command
CMD ["/bin/bash"]
