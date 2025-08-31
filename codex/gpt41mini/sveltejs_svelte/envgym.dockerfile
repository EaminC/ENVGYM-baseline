FROM node:20

# Set working directory to /app in the container
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Copy all repo files
COPY . /app

# Install dependencies
RUN pnpm install

# Start container in bash shell
CMD ["/bin/bash"]
