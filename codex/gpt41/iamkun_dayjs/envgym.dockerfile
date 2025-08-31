# Day.js development environment Dockerfile
FROM ubuntu:20.04

# Avoids some interactive issues
ENV DEBIAN_FRONTEND=noninteractive

# Install core utilities and nodejs/npm (apt for stability)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl gnupg build-essential git \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to repo root
WORKDIR /repo

# Copy everything (use ADD for full context)
ADD . /repo

# Install NPM dependencies
RUN npm install

# Default to bash shell in repo root
CMD ["/bin/bash"]
