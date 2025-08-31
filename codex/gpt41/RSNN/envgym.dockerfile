FROM python:3.8-slim

# Install system dependencies for scientific Python and visualization
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libsndfile1 \
    libhdf5-dev \
    libglib2.0-0 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Create app directory and set as working directory
WORKDIR /app

# Copy all repo files into container
COPY . /app

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Default to bash shell in repo root
CMD ["/bin/bash"]
