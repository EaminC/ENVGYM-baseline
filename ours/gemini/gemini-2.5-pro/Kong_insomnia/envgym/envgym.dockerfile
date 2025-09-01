FROM node:18-bookworm-slim

ARG NODE_AUTH_TOKEN

# Set non-interactive mode for package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install system-level dependencies required for development and runtime.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    libfontconfig-dev \
    libcurl4-openssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the entire repository context
COPY . .

# Check for NODE_AUTH_TOKEN, create .npmrc, install dependencies, and clean up .npmrc
RUN if [ -z "$NODE_AUTH_TOKEN" ]; then \
      echo "Error: Build-time variable NODE_AUTH_TOKEN is not set." >&2; \
      echo "Please provide it using the --build-arg NODE_AUTH_TOKEN=<your_token> flag." >&2; \
      exit 1; \
    fi && \
    echo "//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}" > .npmrc && \
    npm ci && \
    rm .npmrc

# Build the inso artifact inside the container
RUN npm run artifacts -w insomnia-inso

# Make the inso executable available system-wide
RUN cp packages/insomnia-inso/artifacts/inso /usr/local/bin/

# Provide a bash shell as the default command.
# The user will be at the root of the repository (/app) with 'inso' available.
CMD ["/bin/bash"]