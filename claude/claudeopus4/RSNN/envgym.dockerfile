# Use Python 3.10.12 as specified in the README
FROM python:3.10.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libhdf5-dev \
    libsndfile1 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace/RSNN

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the entire repository
COPY . .

# Install the repository in editable mode if setup.py exists
RUN if [ -f setup.py ]; then pip install -e .; fi

# Set environment variables for better interactive experience
ENV PYTHONUNBUFFERED=1
ENV TERM=xterm-256color

# Default command: interactive bash shell
CMD ["/bin/bash"]