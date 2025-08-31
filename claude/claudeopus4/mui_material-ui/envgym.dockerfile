# Material-UI Development Environment Dockerfile
FROM node:20-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally at the specific version required by the project
RUN npm install -g pnpm@10.15.0

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Install dependencies using pnpm
RUN pnpm install --frozen-lockfile

# Build the project
RUN pnpm build

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Default command is to start bash at the repository root
CMD ["/bin/bash"]