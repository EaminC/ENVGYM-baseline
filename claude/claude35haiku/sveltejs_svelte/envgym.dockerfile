# Dockerfile for Svelte.js repository development environment
FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.4.0 --activate

# Set working directory
WORKDIR /svelte

# Copy the entire repository
COPY . .

# Install dependencies
RUN pnpm install

# Set default command to bash
CMD ["/bin/bash"]