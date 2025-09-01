# --- Stage 1: Development Environment ---
# This stage installs dependencies and prepares the project for development.
# It uses a Node.js LTS image compatible with the linux/amd64 architecture.
FROM --platform=linux/amd64 node:20-bookworm-slim

# Set the working directory inside the container.
WORKDIR /app

# Copy package manifests and lockfile first to leverage Docker layer caching.
# This prevents re-installing dependencies on every source code change.
COPY package.json yarn.lock ./

# The material-ui repository is a monorepo. We need the top-level package.json
# from each workspace to be present for yarn to construct the dependency tree correctly.
# Copying the packages directory structure is necessary before installation.
COPY packages/ packages/

# Install dependencies using Yarn.
# This CPU-intensive step will be accelerated by the high core count (96) of the host machine.
RUN yarn install --frozen-lockfile --ignore-scripts

# Copy the rest of the source code into the container.
COPY . .

# Build the project, including the documentation site.
# This is a highly parallelizable, CPU-bound task that will significantly benefit from 96 cores.
RUN yarn docs:build

# Set the default command to a bash shell for an interactive development environment.
CMD ["/bin/bash"]