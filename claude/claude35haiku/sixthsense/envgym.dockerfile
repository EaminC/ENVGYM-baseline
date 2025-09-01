FROM python:3.8-slim-buster

# Set working directory
WORKDIR /sixthsense

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire repository
COPY . .

# Create necessary directories
RUN mkdir -p plots models results

# Set default command to bash
CMD ["/bin/bash"]