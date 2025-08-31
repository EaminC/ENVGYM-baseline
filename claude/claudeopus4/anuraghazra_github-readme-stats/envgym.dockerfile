# GitHub Readme Stats Development Environment
FROM node:22-slim

# Install essential packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the entire repository
COPY . .

# Set up git safe directory (useful for development)
RUN git config --global --add safe.directory /app

# Default command to start bash shell
CMD ["/bin/bash"]