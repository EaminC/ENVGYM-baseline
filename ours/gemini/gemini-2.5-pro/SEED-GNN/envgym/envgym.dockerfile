# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set environment variables to prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies, including git
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory to the parent path specified in the plan
WORKDIR /home/cc/EnvGym/data

# Clone the project repository
RUN git clone https://github.com/henryzhongsc/gnn_editing.git SEED-GNN

# Set the working directory to the root of the cloned repository
WORKDIR /home/cc/EnvGym/data/SEED-GNN

# Install Python dependencies using pip, ensuring CPU-only versions for PyTorch and PyG
# Step 1: Install PyTorch core libraries for CPU
RUN pip install --no-cache-dir \
    torch==2.0.0 \
    torchvision==0.15.1 \
    torchaudio==2.0.1 \
    --index-url https://download.pytorch.org/whl/cpu

# Step 2: Install PyTorch Geometric dependencies for the specific CPU version of PyTorch
RUN pip install --no-cache-dir \
    torch-scatter==2.1.1 \
    torch-cluster==1.6.1 \
    torch-spline-conv==1.2.2 \
    torch-sparse==0.6.17 \
    -f https://data.pyg.org/whl/torch-2.0.0+cpu.html

# Step 3: Install the remaining packages from the requirements.txt file
RUN pip install --no-cache-dir -r requirements.txt

# Create the necessary directories for data and outputs as per the plan
RUN mkdir data outputs

# Set the default command to start a bash shell, placing the user in the project root
CMD ["/bin/bash"]