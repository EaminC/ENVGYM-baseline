# Use Node.js official image as base
FROM node:20-slim

# Install additional dependencies that might be needed for building and testing
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /axios

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the entire repository
COPY . .

# Build the project
RUN npm run build

# Set the default command to bash
CMD ["/bin/bash"]