FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    gcc \
    g++ \
    python3-dev \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh

# Set up shell
SHELL ["/bin/bash", "-c"]

# Set PATH and conda initialization
ENV PATH /opt/conda/bin:$PATH
RUN /opt/conda/bin/conda init bash

# Set environment variables for performance
ENV OPENBLAS_NUM_THREADS=96
ENV MKL_NUM_THREADS=96
ENV OMP_NUM_THREADS=96

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Debug and setup
RUN source ~/.bashrc && \
    conda info && \
    conda config --show && \
    python --version && \
    pip --version

# Install requirements in base environment
RUN source ~/.bashrc && \
    conda run -n base pip install --no-cache-dir -r requirements.txt

# Prepare directories
RUN mkdir -p plots models results csvs

# Make install script executable
RUN chmod +x install.sh

# Default command
CMD ["/bin/bash"]