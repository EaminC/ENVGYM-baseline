FROM node:18

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    chromium \
    firefox-esr \
    && rm -rf /var/lib/apt/lists/*

# Install Deno (optional)
RUN curl -fsSL https://deno.land/x/install/install.sh | sh
ENV PATH="/root/.deno/bin:${PATH}"

# Create working directory
WORKDIR /home/cc/EnvGym/data/darkreader_darkreader

# Clone repository
RUN git clone https://github.com/darkreader/darkreader.git .

# Install Node.js dependencies
RUN npm install

# Create required files with proper directory structure
RUN mkdir -p build && \
    touch .env tests/test-config.js build/custom-flags.json deno.json

# Set up environment variables for testing
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Build the extension
RUN npm run build
RUN npm run build:firefox

# Set default command to bash at project root
CMD ["/bin/bash"]