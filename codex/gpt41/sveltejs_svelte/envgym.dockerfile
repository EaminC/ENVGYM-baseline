# syntax=docker/dockerfile:1
FROM node:20-bullseye

# Set up locale and basic tools
RUN apt-get update && \
    apt-get install -y bash git && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@10.4.0

# Copy repo code into container and set workdir
WORKDIR /repo
COPY . /repo

# Install dependencies via pnpm
RUN pnpm install --frozen-lockfile

# Default shell
CMD ["/bin/bash"]
