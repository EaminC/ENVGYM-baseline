FROM python:3.7-slim

# Set working directory
WORKDIR /sixthsense

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository
COPY . /sixthsense/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Create required directories
RUN mkdir -p plots models results

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set the default command to bash
CMD ["/bin/bash"]