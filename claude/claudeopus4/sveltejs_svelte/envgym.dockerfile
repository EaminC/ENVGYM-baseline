# Dockerfile for Svelte development environment
FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@10.4.0 --activate

# Set working directory
WORKDIR /svelte

# Copy package files
COPY package.json pnpm-workspace.yaml ./
COPY packages/svelte/package.json ./packages/svelte/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the entire repository
COPY . .

# Build the packages
RUN pnpm build

# Set the default command to bash
CMD ["/bin/bash"]