FROM node:22-slim AS base
LABEL maintainer="DevOps Team"

# Platform and architecture configuration
ARG TARGETPLATFORM=linux/amd64
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Set environment variables
ENV NODE_ENV=development
ENV NODE_OPTIONS="--max-old-space-size=16384"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Vercel CLI and global npm packages
RUN npm install -g \
    vercel \
    eslint \
    prettier \
    husky \
    jest \
    npm@latest

# Set working directory
WORKDIR /app

# Copy project files
COPY package*.json ./
COPY . .

# Install project dependencies
RUN npm ci --quiet \
    && npm cache clean --force

# Configure development environment
RUN npm run prepare

# Conditional performance optimization with error handling
RUN npm run lint:performance || true

# Expose potential development ports
EXPOSE 3000 8080

# Set default command
CMD ["/bin/bash"]