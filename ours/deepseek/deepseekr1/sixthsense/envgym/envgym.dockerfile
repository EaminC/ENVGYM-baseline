# syntax=docker/dockerfile:1.4
FROM continuumio/miniconda3:4.7.12
WORKDIR /app

# Use archived Debian buster repositories
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

# Install system dependencies with cache optimization
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Create required directories including csvs
RUN mkdir -p plots models results csvs

# Download and extract dataset with updated URL
RUN wget -O dataset.zip "https://zenodo.org/record/6388301/files/sixthsense-dataset-v2.0.zip?download=1" && \
    unzip dataset.zip -d csvs/ && \
    rm dataset.zip

# Configure conda environment
RUN conda create -y -n ssense python=3.7 && \
    echo "conda activate ssense" >> ~/.bashrc
ENV PATH /opt/conda/envs/ssense/bin:$PATH

# Install Python dependencies with cache optimization
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Copy application files
COPY install.sh README.md train.py utils.py ./
COPY subcategories ./subcategories

# Default command (interactive shell)
CMD ["/bin/bash"]