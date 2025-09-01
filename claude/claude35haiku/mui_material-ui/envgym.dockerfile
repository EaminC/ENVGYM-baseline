FROM node:20-alpine

# Install system dependencies
RUN apk add --no-cache bash git

# Install pnpm
RUN npm install -g pnpm@10.15.0

# Set working directory
WORKDIR /mui

# Copy package management files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages
COPY packages-internal ./packages-internal
COPY scripts ./scripts

# Install dependencies
RUN pnpm install --frozen-lockfile

# Set default command to bash
CMD ["/bin/bash"]