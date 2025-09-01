# Use official Python 3.8 base image
FROM python:3.8

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /home/cc/EnvGym/data/SEED-GNN

# Install Python dependencies in separate steps to avoid conflicts
RUN pip install --upgrade pip
RUN pip install numpy==1.24.4 pandas==2.0.3
RUN pip install torch==2.0.0+cpu --index-url https://download.pytorch.org/whl/cpu --no-deps
RUN pip install torch-scatter==2.1.1+pt20cpu torch-cluster==1.6.1+pt20cpu torch-spline-conv==1.2.2+pt20cpu torch-sparse==0.6.17+pt20cpu -f https://data.pyg.org/whl/torch-2.0.0+cpu.html
RUN pip install torch-geometric==2.3.1 --no-deps
RUN pip install torchvision==0.15.1 torchaudio==2.0.2 --no-deps
RUN pip install ogb==1.3.6

# Create necessary directories
RUN mkdir -p config/pipeline_config/seed_gnn/gcn && \
    mkdir -p config/eval_config/edit_gnn && \
    mkdir -p scripts/pretrain/seed_gnn && \
    mkdir -p scripts/edit/seed_gnn/gcn

# Copy repository contents
COPY . .

# Set default command
CMD ["/bin/bash"]