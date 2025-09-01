# Multi-stage Dockerfile for x86_64 Linux environment
FROM node:18-bullseye AS builder

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN apt-get update && apt-get install -y git curl
RUN corepack enable && \
    corepack prepare pnpm@7 --activate && \
    pnpm install --frozen-lockfile || \
    { echo "pnpm installation failed"; exit 1; }
COPY . .
RUN pnpm run build && \
    mkdir -p /app/dist && \
    ls -la /app

FROM node:18-bullseye

ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/README.md ./

RUN chmod -R 755 /app/scripts && \
    chown -R node:node /app

USER node
WORKDIR /app
CMD ["/bin/bash"]