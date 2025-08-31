FROM node:20-slim

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install dependencies
RUN pnpm install

# Build the project using lerna
RUN pnpm run build

# Start a bash shell
CMD ["/bin/bash"]
