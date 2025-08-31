FROM ubuntu:22.04

# Install dependencies: Node.js, npm, Electron prerequisites, etc.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y curl gnupg build-essential git libfontconfig-dev ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@10 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Electron config env vars (optional)
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1 \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true

# Set up workdir and copy source
WORKDIR /workspace
COPY . /workspace

# Install all Node.js monorepo deps
RUN npm install

# Default to interactive bash in repo root
CMD ["/bin/bash"]
