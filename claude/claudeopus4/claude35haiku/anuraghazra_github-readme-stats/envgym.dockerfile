# Use official Node.js image with version 22
FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install git and bash for CLI access
RUN apk add --no-cache git bash

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the entire project
COPY . .

# Set default command to bash
CMD ["/bin/bash"]