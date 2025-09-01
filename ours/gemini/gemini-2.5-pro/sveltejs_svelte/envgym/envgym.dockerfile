# 1. Prepare the Environment: Use a linux/amd64 base image with Node.js LTS (v20)
FROM node:20-bullseye

# Set the working directory
WORKDIR /app

# Update package lists and install necessary system dependencies for Git, build tools, and Playwright
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    # Playwright dependencies for Chromium
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy Source Code
# Copy the entire project source from the host into the container's working directory
COPY . .

# 3. Configure Package Manager
# Enable corepack to use the pnpm version specified in package.json
RUN corepack enable

# 4. Install Project Dependencies
# This will use the pnpm-lock.yaml file for a deterministic install.
# The .npmrc file will be respected, skipping the automatic browser download.
RUN pnpm install

# 5. Install Playwright Browsers
# Manually install the Chromium browser required for end-to-end tests
RUN pnpm playwright install chromium

# 6. Build the Project Packages
# This script bundles the compiler, generates types, and runs checks like tree-shakeability
RUN pnpm build

# 6.1. Configure Git and commit any generated files to ensure a clean working directory
RUN git config --global user.name "builder" && git config --global user.email "builder@example.com"
RUN git add . && git commit -m "chore: commit generated files from build"

# 6.2. Crucial Verification: Ensure the build process doesn't create uncommitted changes
# This is a critical CI check to ensure generated files (like type definitions) are up-to-date
RUN if [ -n "$(git status --porcelain)" ]; then echo "Git directory is not clean after build. Please commit generated files."; git status; git diff; exit 1; fi

# Set the final command to start a bash shell, putting the user in the fully configured environment
CMD ["/bin/bash"]