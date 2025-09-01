# Stage 1: Build stage
FROM node:20-alpine AS base
RUN apk add --no-cache --virtual .build-deps \
    python3 \
    make \
    g++
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && \
    corepack prepare pnpm@8.15.7 --activate
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
RUN apk del .build-deps

# Stage 2: Interactive runtime
FROM node:20-alpine
RUN apk add --no-cache bash
WORKDIR /app
COPY --chown=node:node --from=base /app /app
USER node
EXPOSE 3000
CMD ["/bin/bash"]