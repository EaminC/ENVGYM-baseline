# Use an official Python runtime as a parent image
FROM python:3.10.12-slim

# Install system dependencies required by the project
# git is needed for pip packages installed from git repos
# wget and unzip are for downloading and extracting the dataset
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Define the project root directory inside the container
ENV PROJECT_ROOT=/home/cc/EnvGym/data/RSNN

# Set the working directory
WORKDIR ${PROJECT_ROOT}

# Copy the entire project context into the working directory
COPY . .

# Install Python dependencies
# First, install the CPU-only version of PyTorch to ensure no GPU-specific version is pulled
# This overrides any torch version specified in requirements.txt
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install the stork package from Git, which requires the #egg syntax
RUN pip install --no-cache-dir "git+https://github.com/fmi-basel/stork.git@40c68fe#egg=stork"

# Now, install all other packages from requirements.txt, excluding torch and stork which were manually installed
RUN grep -vE 'torch|stork' requirements.txt | pip install --no-cache-dir -r /dev/stdin

# Download and extract the dataset into the 'data' directory
RUN mkdir data && \
    wget -O data/dataset.zip "https://zenodo.org/records/5947321/files/dataset.zip" && \
    unzip data/dataset.zip -d data/ && \
    rm data/dataset.zip

# Apply mandatory configuration changes for a CPU-only environment using sed
# 1. Set the data directory path in the data configuration file
RUN sed -i "s|^\(\s*data_dir:\s*\).*|\1${PROJECT_ROOT}/data|" conf/data/data-default.yaml

# 2. Set the device to 'cpu' in the main defaults configuration file
RUN sed -i 's|^\(\s*device:\s*\).*|\1"cpu"|' conf/defaults.yaml

# 3. Ensure half-precision is disabled in the evaluation configuration, as it's not supported on CPU
RUN sed -i 's|^\(\s*half:\s*\).*|\1False|' conf/evaluation/eval-default.yaml

# Set the default command to execute when the container starts.
# This will drop the user into a bash shell in the project's root directory.
CMD ["/bin/bash"]