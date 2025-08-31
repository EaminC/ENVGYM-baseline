# DarkReader Development Environment
FROM node:20-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    build-essential \
    python3 \
    chromium \
    firefox-esr \
    xvfb \
    libgtk-3-0 \
    libgbm-dev \
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxss1 \
    libasound2 \
    fonts-liberation \
    libappindicator3-1 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /darkreader

# Copy the repository
COPY . .

# Install Node.js dependencies
RUN npm install

# Build the project
RUN npm run build

# Set environment variables for headless browser testing
ENV CHROME_BIN=/usr/bin/chromium
ENV FIREFOX_BIN=/usr/bin/firefox-esr
ENV DISPLAY=:99

# Create a non-root user for better security
RUN useradd -m -s /bin/bash darkreader && \
    chown -R darkreader:darkreader /darkreader

# Switch to non-root user
USER darkreader

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default command - start bash at the repository root
CMD ["/bin/bash"]