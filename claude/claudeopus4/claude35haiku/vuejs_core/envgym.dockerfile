# Vue.js Core Development Environment Dockerfile
FROM node:22.14.0

# Install pnpm
RUN npm install -g pnpm@10.15.0

# Set working directory
WORKDIR /vue-core

# Copy project files
COPY . .

# Install dependencies
RUN pnpm install

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Default command to start a bash shell
CMD ["/bin/bash"]