# Development environment for Insomnia
FROM node:22.17.1-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    python3 \
    git \
    curl \
    libgtk-3-0 \
    libnotify-dev \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libatspi2.0-0 \
    libdrm2 \
    libgbm1 \
    libxcb-dri3-0 \
    libxkbcommon0 \
    libxrandr2 \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libx11-xcb1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy package files first for better caching
COPY package*.json ./
COPY .npmrc ./
COPY packages/insomnia/package*.json ./packages/insomnia/
COPY packages/insomnia-inso/package*.json ./packages/insomnia-inso/
COPY packages/insomnia-testing/package*.json ./packages/insomnia-testing/
COPY packages/insomnia-smoke-test/package*.json ./packages/insomnia-smoke-test/
COPY packages/insomnia-scripting-environment/package*.json ./packages/insomnia-scripting-environment/

# Install dependencies
RUN npm ci

# Copy the entire repository
COPY . .

# Set environment variables for Electron
ENV ELECTRON_DISABLE_SANDBOX=1
ENV NODE_ENV=development

# Default command is bash
CMD ["/bin/bash"]