# Dockerfile for RSNN Development Environment
FROM python:3.10.12-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app/RSNN

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Clone additional repositories specified in requirements
RUN pip install -e git+https://github.com/fmi-basel/stork.git@40c68fe#egg=stork \
    && pip install git+https://github.com/fzenke/randman

# Copy entire repository
COPY . .

# Set default command to bash
CMD ["/bin/bash"]