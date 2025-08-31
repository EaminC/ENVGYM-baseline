FROM node:22

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy all source files
COPY . .

# Start with an interactive bash shell
CMD ["bash"]
