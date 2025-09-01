FROM node:22.17.1-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /insomnia

# Copy the entire repository
COPY . .

# Install global dependencies
RUN npm install -g npm@10

# Install project dependencies
RUN npm install

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]