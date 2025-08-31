# syntax=docker/dockerfile:1
FROM python:3.8-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y git bash build-essential && \
    rm -rf /var/lib/apt/lists/*

# Set working directory at repo root
WORKDIR /Lottory

# Copy repo contents to image
COPY . /Lottory

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Set entrypoint to bash shell at repo root
ENTRYPOINT ["/bin/bash"]
