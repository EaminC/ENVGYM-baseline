# syntax = docker/dockerfile:1
FROM node:20.12.2-alpine AS builder
WORKDIR /app

# Copy package files and lock file
COPY package.json .
COPY pnpm-lock.yaml .
COPY pnpm-workspace.yaml .
COPY packages/*/package.json ./packages/
COPY packages-private/*/package.json ./packages-private/

# Set up pnpm
ENV PNPM_HOME=/root/.pnpm
ENV PNPM_STORE_DIR=/root/.pnpm-store
ENV PATH="$PATH:$PNPM_HOME"
# Install pnpm globally and run pnpm install with cache
RUN --mount=type=cache,target=/root/.npm \
    npm install -g pnpm
RUN --mount=type=cache,target=$PNPM_STORE_DIR \
    pnpm install --frozen-lockfile

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    python3 \
    make \
    g++ \
    git

# Copy all remaining files
COPY . .

# Build with increased memory allocation
ENV NODE_OPTIONS=--max_old_space_size=4096
RUN pnpm run build

# Final stage
FROM node:20.12.2-alpine
RUN apk add --no-cache bash
WORKDIR /app
COPY --from=builder /app /app
CMD ["/bin/bash"]