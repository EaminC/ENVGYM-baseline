FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install necessary build tools
RUN apk add --no-cache bash git

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the entire project
COPY . .

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]

# Keep the container running (optional, for interactive use)
CMD [""]