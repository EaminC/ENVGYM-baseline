FROM node:20-slim AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json ./
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    npm ci --omit=dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM base AS builder
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm install typescript@5 eslint@8 rollup jest karma prettier ts-node @types/node type-fest webextension-polyfill && \
    npm run build

FROM base AS runtime
RUN adduser --disabled-password --gecos '' cc
USER cc
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app ./
VOLUME /app/node_modules
EXPOSE 3000
CMD ["/bin/bash"]