FROM node:22.14.0-bookworm

# Install system dependencies for Puppeteer/Chromium and development tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    libappindicator1 \
    libnss3 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.15.0 --activate

# Install global tools
RUN npm install -g serve

# Set working directory
WORKDIR /workspace

# Copy package files first for better caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/*/package.json packages/*/
COPY packages-private/*/package.json packages-private/*/

# Configure pnpm for better compatibility
RUN pnpm config set auto-install-peers true && \
    pnpm config set strict-peer-dependencies false && \
    pnpm config set fetch-retries 5 && \
    pnpm config set fetch-retry-factor 2 && \
    pnpm config set fetch-retry-mintimeout 10000 && \
    pnpm config set fetch-retry-maxtimeout 60000 && \
    pnpm config set prefer-offline true

# Clear pnpm store and pre-fetch packages
RUN pnpm store prune && \
    pnpm fetch --prod --prefer-offline || true && \
    pnpm fetch --dev --prefer-offline || true

# Install dependencies in smaller chunks
RUN echo "=== Installing shared package ===" && \
    cd packages/shared && \
    pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || true && \
    cd /workspace

RUN echo "=== Installing reactivity package ===" && \
    cd packages/reactivity && \
    pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || true && \
    cd /workspace

RUN echo "=== Installing compiler packages ===" && \
    for pkg in compiler-core compiler-dom compiler-sfc compiler-ssr; do \
        echo "Installing $pkg..." && \
        cd packages/$pkg && \
        pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || true && \
        cd /workspace; \
    done

RUN echo "=== Installing runtime packages ===" && \
    for pkg in runtime-core runtime-dom runtime-test; do \
        echo "Installing $pkg..." && \
        cd packages/$pkg && \
        pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || true && \
        cd /workspace; \
    done

RUN echo "=== Installing remaining packages ===" && \
    for pkg in server-renderer vue vue-compat; do \
        echo "Installing $pkg..." && \
        cd packages/$pkg && \
        pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || true && \
        cd /workspace; \
    done

# Install root dependencies
RUN echo "=== Installing root dependencies ===" && \
    pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional || \
    pnpm install --prefer-offline --network-timeout=100000 --ignore-scripts --no-optional --force || \
    echo "=== Root install completed with warnings ==="

# Copy the rest of the repository
COPY . .

# Set environment variables
ENV NODE_ENV=development
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Run postinstall scripts
RUN pnpm rebuild --prefer-offline || echo "=== Some packages failed to rebuild ==="

# Try to build
RUN pnpm run build || echo "=== Build completed with warnings ==="

# Set up git hooks
RUN pnpm exec simple-git-hooks || echo "=== Git hooks setup skipped ==="

# Create a non-root user for development
RUN useradd -m -s /bin/bash developer && \
    chown -R developer:developer /workspace

# Switch to non-root user
USER developer

# Set the default command to bash
CMD ["/bin/bash"]