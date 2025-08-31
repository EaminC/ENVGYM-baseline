FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3.8-dev \
    python3-pip \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.8 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# Install Miniconda for conda environment management
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add conda to PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Initialize conda for bash
RUN /opt/conda/bin/conda init bash

# Create a conda environment with R packages
RUN conda create -n flex python=3.8 -y && \
    conda install -n flex -c conda-forge r-base r-eva -y

# Set working directory
WORKDIR /workspace/flex

# Copy the repository files
COPY . .

# Activate conda environment and install Python requirements
SHELL ["/bin/bash", "-c"]
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate flex && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Create projects directory as mentioned in README
RUN mkdir -p projects

# Set up bash to automatically activate the conda environment
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate flex" >> ~/.bashrc

# Set the default command to bash
CMD ["/bin/bash"]