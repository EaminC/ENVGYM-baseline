# TabPFN development & CLI Dockerfile
FROM python:3.9-slim

# (Optional) Install system dependencies and CUDA. Comment below as needed.
RUN apt-get update && apt-get install -y build-essential git curl wget && rm -rf /var/lib/apt/lists/*

# CUDA support (uncomment to enable, customize as needed)
# RUN apt-get update && apt-get install -y cuda-toolkit-11-4 && rm -rf /var/lib/apt/lists/*

# Set working directory to repo root
WORKDIR /workspace

# Copy repo into image
COPY . /workspace

# Upgrade pip and install hatch for modern PEP 517 builds
RUN pip install --upgrade pip setuptools wheel

# Install dependencies and TabPFN in editable dev mode
RUN pip install -e ".[dev]"

# Default: drop user into interactive bash at repo root
CMD ["/bin/bash"]
