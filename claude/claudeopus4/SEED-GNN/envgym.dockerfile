# SEED-GNN Environment Dockerfile
# This Dockerfile sets up the complete environment for SEED-GNN research project
# Based on PyTorch 2.0.0 with CUDA 11.7 support for Graph Neural Network editing

FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-devel

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_VERSION=cu117

# Set working directory
WORKDIR /workspace/SEED-GNN

# Update system packages and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    vim \
    htop \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch Geometric and related packages first
# Following the specific installation order from README
RUN pip install --no-cache-dir \
    torch-scatter==2.1.1 \
    torch-cluster==1.6.1 \
    torch-spline-conv==1.2.2 \
    torch-sparse==0.6.17 \
    -f https://data.pyg.org/whl/torch-2.0.0+cu117.html

# Copy requirements file first for better Docker layer caching
COPY requirements.txt /workspace/SEED-GNN/requirements.txt

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire repository
COPY . /workspace/SEED-GNN/

# Install the repository in development mode if setup.py exists
# Otherwise, ensure Python path includes current directory
RUN if [ -f setup.py ]; then \
        pip install -e .; \
    else \
        echo "No setup.py found, repository will be used as-is"; \
    fi

# Create directories for outputs and datasets
RUN mkdir -p /workspace/data \
    && mkdir -p /workspace/outputs \
    && mkdir -p /workspace/SEED-GNN/results

# Set permissions
RUN chmod -R 755 /workspace/SEED-GNN

# Verify installation by testing imports
RUN python -c "import torch; import torch_geometric; import numpy; import pandas; print('✅ All core dependencies imported successfully')" \
    && python -c "import sys; sys.path.append('/workspace/SEED-GNN'); import constants; print('✅ SEED-GNN imports working')"

# Set up bash as default shell with helpful aliases
RUN echo 'alias ll="ls -la"' >> /root/.bashrc \
    && echo 'alias la="ls -la"' >> /root/.bashrc \
    && echo 'export PS1="[\u@seed-gnn \W]$ "' >> /root/.bashrc

# Expose common ports (optional, for Jupyter or other services)
EXPOSE 8888 6006

# Default command starts bash in the repository root
CMD ["/bin/bash"]

# Build instructions:
# docker build -f envgym.dockerfile -t seed-gnn:latest .
#
# Run instructions:
# docker run -it --rm -v $(pwd)/data:/workspace/data -v $(pwd)/outputs:/workspace/outputs seed-gnn:latest
#
# For GPU support (if available):
# docker run -it --rm --gpus all -v $(pwd)/data:/workspace/data -v $(pwd)/outputs:/workspace/outputs seed-gnn:latest