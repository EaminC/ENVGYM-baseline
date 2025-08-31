FROM node:20-alpine

# Install bash and other necessary tools
RUN apk add --no-cache bash git

# Set working directory
WORKDIR /express

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the entire repository
COPY . .

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default command to start bash at the root of the repository
CMD ["/bin/bash"]