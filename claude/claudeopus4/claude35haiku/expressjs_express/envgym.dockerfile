# Environment Gym Dockerfile for Express.js

# Use official Node.js 18 image
FROM node:18-bullseye

# Set working directory
WORKDIR /express

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository
COPY . .

# Install dependencies
RUN npm install

# Set default command to bash
CMD ["/bin/bash"]