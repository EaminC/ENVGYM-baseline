# Day.js Development Environment Dockerfile
# This Dockerfile creates a development environment for the Day.js library

FROM node:lts

# Set working directory to /dayjs (repository root inside container)
WORKDIR /dayjs

# Install additional useful development tools
RUN apt-get update && apt-get install -y \
    git \
    vim \
    nano \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the entire repository
COPY . .

# Build the project
RUN npm run build

# Set bash as the default command
CMD ["/bin/bash"]