# Use the official Node.js 18 LTS image based on Debian Bullseye
FROM node:18-bullseye

# Set environment variable to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites: Git for version control, curl for downloading, and Chromium for headless browser testing
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Set an environment variable for Karma to find the headless Chrome browser
ENV CHROME_BIN=/usr/bin/chromium

# Create a non-root user 'cc' with a home directory and bash as the default shell
RUN useradd -m -s /bin/bash cc

# Create the specified directory structure and set ownership to the 'cc' user
RUN mkdir -p /home/cc/EnvGym/data && \
    chown -R cc:cc /home/cc/EnvGym

# Switch to the non-root user
USER cc

# Set the working directory for cloning the repository
WORKDIR /home/cc/EnvGym/data

# Clone the axios repository into a directory named 'axios_axios'
RUN git clone https://github.com/axios/axios.git axios_axios

# Set the final working directory to the project root
WORKDIR /home/cc/EnvGym/data/axios_axios

# Install project dependencies using npm ci for a clean, reproducible build from package-lock.json
# This also runs the 'prepare' script which sets up Husky Git hooks
RUN npm ci

# Expose port 3000 for running the examples server
EXPOSE 3000

# Set the default command to start a bash shell in the project's root directory
CMD ["/bin/bash"]