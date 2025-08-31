FROM node:18

# Install global pnpm
RUN npm install -g pnpm@10.15.0

# Create app directory
WORKDIR /usr/src/app

# Copy all files
COPY . .

# Install dependencies
RUN pnpm install

# Default command
CMD ["/bin/bash"]
