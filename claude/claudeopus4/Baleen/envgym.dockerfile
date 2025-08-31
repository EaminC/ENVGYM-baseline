# Dockerfile for Baleen development environment
FROM continuumio/miniconda3:latest

# Set working directory
WORKDIR /workspace/Baleen

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    wget \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository
COPY . /workspace/Baleen

# Initialize conda and create environment from yaml file
RUN conda env create -f /workspace/Baleen/BCacheSim/install/env_cachelib-py-3.11.yaml

# Make RUN commands use the new environment
SHELL ["conda", "run", "-n", "cachelib-py-3.11", "/bin/bash", "-c"]

# Ensure the environment is activated on container start
RUN echo "conda activate cachelib-py-3.11" >> ~/.bashrc

# Download trace data (optional - comment out if you want to do this manually)
# RUN cd /workspace/Baleen/data && bash get-tectonic.sh

# Set up git submodules
RUN cd /workspace/Baleen && \
    git submodule init && \
    git submodule update

# Default command - start bash shell
CMD ["/bin/bash"]