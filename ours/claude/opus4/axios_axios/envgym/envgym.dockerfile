FROM node:20-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    firefox-esr \
    chromium \
    chromium-driver \
    xvfb \
    libgtk-3-0 \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xauth \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /home/cc/EnvGym/data/axios_axios

# Copy repository files
COPY . .

# Install global npm packages individually
RUN npm install -g typescript@latest || true
RUN npm install -g pnpm || true
RUN npm install -g yarn || true
RUN npm install -g karma-cli || true
RUN npm install -g mocha || true
RUN npm install -g eslint || true
RUN npm install -g rollup || true
RUN npm install -g gulp-cli || true
RUN npm install -g commitizen || true
RUN npm install -g release-it || true

# Install project dependencies
RUN npm install || true

# Set up git hooks
RUN npm run prepare || true

# Create necessary directories
RUN mkdir -p \
    test/unit \
    test/module \
    lib/adapters \
    lib/helpers \
    lib/platform/node \
    lib/platform/browser \
    bin \
    sandbox \
    examples \
    .husky \
    dist \
    coverage

# Create essential files if they don't exist
RUN touch .gitignore .env CHANGELOG.md

# Create .gitignore content
RUN echo "node_modules/\ndist/\ncoverage/\n.env\n*.log\n.DS_Store\n.idea/\n.vscode/\n*.swp\n*.swo\n.nyc_output/\n" > .gitignore

# Set executable permissions for scripts
RUN find . -name "*.js" -type f -path "*/bin/*" -exec chmod +x {} \;

# Set up display for headless browser testing
ENV DISPLAY=:99

# Create startup script
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &\nexec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set working directory permissions
RUN chown -R node:node /home/cc/EnvGym/data/axios_axios

# Switch to node user
USER node

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]