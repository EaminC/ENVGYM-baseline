# Vue.js Core Development Environment
FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally (specified version from package.json)
RUN npm install -g pnpm@10.15.0

# Set working directory
WORKDIR /workspace

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Copy all necessary files for installation
COPY packages ./packages
COPY packages-private ./packages-private
COPY scripts ./scripts
COPY tsconfig*.json ./
COPY vitest*.config.ts vitest.workspace.ts ./
COPY rollup*.config.js ./
COPY eslint.config.js ./
COPY .prettierrc .prettierignore ./

# Install dependencies
RUN pnpm install

# Copy remaining source files
COPY . .

# Set the default command to bash
CMD ["/bin/bash"]