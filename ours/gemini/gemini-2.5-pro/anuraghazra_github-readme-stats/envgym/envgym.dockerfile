# Use the official Node.js 22 image based on Debian Bookworm Slim as the base image.
# This provides Node.js, npm, and a minimal Linux environment.
FROM node:22-bookworm-slim

# Set an environment variable to prevent interactive prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install initial dependencies.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    python3 \
    python3-pip

# Download and install the GitHub CLI directly to avoid GPG key issues.
# We download the .deb package and install it with dpkg.
RUN curl -sSL https://github.com/cli/cli/releases/download/v2.52.0/gh_2.52.0_linux_amd64.deb -o gh.deb && \
    dpkg -i gh.deb && \
    apt-get install -f -y && \
    rm gh.deb

# Clean up apt cache to keep the image size small.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the Vercel CLI globally using npm.
# This is required for local development and simulating the Vercel environment.
RUN npm install -g vercel

# Create and set the working directory for the application.
WORKDIR /app

# Clone the project repository into the working directory.
# Using --depth 1 for a faster clone as the full git history is not needed for the runtime environment.
RUN git clone --depth 1 https://github.com/anuraghazra/github-readme-stats.git .

# Install all project dependencies defined in package.json using npm.
# This command also triggers the 'prepare' script, which sets up Husky pre-commit hooks.
RUN npm install

# Create a default .env file with a placeholder token.
# This ensures the application can start, and the user is prompted to add their own token.
RUN echo "# GitHub Personal Access Token (PAT) for accessing the GitHub API" > .env && \
    echo "# Create one at https://github.com/settings/tokens" >> .env && \
    echo "GITHUB_TOKEN=your_personal_access_token_here" >> .env

# Expose the default port used by 'vercel dev'.
EXPOSE 3000

# Set the default command to launch a bash shell.
# This provides an interactive CLI environment within the container,
# with the repository and all dependencies ready for use.
CMD ["/bin/bash"]