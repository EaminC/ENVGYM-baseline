# Dockerfile for Baleen repository environment
FROM continuumio/miniconda3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /baleen

# Clone the repository 
RUN git clone --recurse-submodules https://github.com/wonglkd/Baleen-FAST24.git .

# Install Conda environment
COPY BCacheSim/install/env_cachelib-py-3.11.yaml ./environment.yaml
RUN conda env create -f environment.yaml && \
    conda clean -afy

# Activate the conda environment by default
SHELL ["conda", "run", "-n", "cachelib-py-3.11", "/bin/bash", "-c"]

# Download trace files
RUN cd data && \
    bash get-tectonic.sh

# Set default command
CMD ["/bin/bash"]