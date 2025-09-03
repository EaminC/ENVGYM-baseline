FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=20.11.0

# System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    software-properties-common \
    libcurl4-openssl-dev \
    build-essential \
    libssl-dev \
    xz-utils \
    sudo \
    gpg \
    ca-certificates \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libwayland-client0 \
    libwayland-server0 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    fonts-liberation \
    libgdk-pixbuf2.0-0 \
    libegl1 \
    libgl1 \
    libx11-6 \
    libxkbcommon0 \
    libatk1.0-0 \
    libgconf-2-4 \
    libx11-xcb1 \
    libxcursor1 \
    libxss1 \
    libxt6 \
    libxtst6 \
    libappindicator1 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libxkbcommon0 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Setup Node.js environment
ENV NVM_DIR=/root/.nvm
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

RUN . "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

# Install global npm packages
RUN . "$NVM_DIR/nvm.sh" && \
    npm install -g \
    yarn \
    npm@9.5.0 \
    electron@29.0.0 \
    typescript@5.3.3 \
    eslint@8.56.0 \
    vite@5.1.0 \
    patch-package \
    cross-env \
    playwright@1.41.0 \
    vitest@1.2.0

# Prepare Playwright dependencies with verbose logging and error handling
RUN . "$NVM_DIR/nvm.sh" && \
    npx playwright install-deps && \
    PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright \
    npx playwright install chromium firefox webkit --verbose || \
    (echo "Playwright browser installation failed" && exit 1)

# Create a non-root user
RUN useradd -m -s /bin/bash insomnia

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Set permissions
RUN chown -R insomnia:insomnia /app

# Switch to non-root user
USER insomnia

# Initialize shell and install dependencies
RUN bash -l -c '. "$NVM_DIR/nvm.sh" && \
    nvm use ${NODE_VERSION} && \
    npm cache clean --force && \
    npm config set legacy-peer-deps true && \
    npm config set fund false && \
    npm install -g npm@9.5.0 && \
    npm install --verbose && \
    npm audit fix || true'

# Set entrypoint
ENTRYPOINT ["/bin/bash"]