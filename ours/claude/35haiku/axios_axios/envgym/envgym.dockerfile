FROM debian:bullseye-slim AS base
LABEL maintainer="DevOps Team"

ARG NODE_VERSION=16.20.2
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 \
    && npm install -g npm@8.19.4 \
    && npm install -g typescript@4.9.5 ts-node

FROM base AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --loglevel=verbose \
    && npm install husky --save-dev \
    && npm run prepare || true

COPY . .
RUN npm run build

FROM base AS runtime
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -m appuser
USER appuser

COPY --from=builder --chown=appuser:appuser /app /app

EXPOSE 3000

CMD ["/bin/bash"]