FROM node:18-bullseye AS base
WORKDIR /app

# Enable corepack for pnpm management
RUN corepack enable

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential

# Set up pnpm
RUN corepack prepare pnpm@10.15.0 --activate

# Copy package management files
COPY package.json pnpm-lock.yaml ./

# Install dependencies with frozen lockfile
RUN pnpm install --frozen-lockfile

# Copy entire project
COPY . .

# Build project
RUN pnpm run build

# Set Node.js options for large memory utilization
ENV NODE_OPTIONS=--max-old-space-size=187500

# Configure working environment
ENV NODE_ENV=development

# Default command drops into bash shell
CMD ["/bin/bash"]