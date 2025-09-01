# Use the official Node.js 22.14.0 image on a Debian-based linux/amd64 system
FROM node:22.14.0

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system-level dependencies required by the project plan:
# - git: For version control operations.
# - chromium: For running Puppeteer-based E2E tests in a headless environment.
# - build-essential: Includes make, g++, etc., for compiling native Node.js addons.
RUN apt-get update && \
    apt-get install -y \
    git \
    chromium \
    build-essential \
    --no-install-recommends && \
    # Clean up the apt cache to reduce final image size
    rm -rf /var/lib/apt/lists/*

# Enable corepack, which is the standard way to manage pnpm in modern Node.js versions
RUN corepack enable

# Update npm to the latest version for compatibility with release workflows
RUN npm i -g npm@latest

# Set the working directory for the project source code
WORKDIR /home/cc/EnvGym/data/vuejs_core

# Copy package manifests to leverage Docker's layer caching.
# This step is isolated so that dependency installation is only re-run
# when these specific files change, not on every code change.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install all project dependencies using pnpm
RUN pnpm install

# Copy the rest of the project source code into the working directory
COPY . .

# Build the entire project, including TypeScript declaration files
RUN pnpm build --withTypes

# Set the default command to start an interactive bash shell.
# When the container runs, the user will be placed in the project root
# with the environment fully configured and ready for use.
CMD ["/bin/bash"]