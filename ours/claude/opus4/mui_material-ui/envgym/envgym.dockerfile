FROM --platform=linux/amd64 node:18-alpine

# Install basic dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    bash \
    openssh-client \
    ca-certificates

# Set working directory
WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./
COPY yarn.lock* ./
COPY lerna.json* ./
COPY pnpm-lock.yaml* ./
COPY .npmrc* ./
COPY .yarnrc* ./

# Install yarn globally and install dependencies
RUN npm install -g yarn && \
    yarn install --frozen-lockfile || npm install

# Copy the entire project
COPY . .

# Build the project
RUN yarn build || npm run build || echo "Build step skipped"

# Set environment variables
ENV NODE_ENV=development
ENV PATH=/app/node_modules/.bin:$PATH

# Expose common development ports
EXPOSE 3000 3001 4000 5000 8080

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default to bash shell
CMD ["/bin/bash"]