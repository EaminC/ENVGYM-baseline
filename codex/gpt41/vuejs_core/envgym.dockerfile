# Use Node.js as base, match local version
FROM node:22.14.0

# Set working directory to repo root
WORKDIR /repo

# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@10.15.0 --activate

# Copy all contents to /repo
COPY . /repo

# Ensure dependencies are installed
RUN pnpm install

# Start a bash shell in /repo
CMD ["/bin/bash"]
