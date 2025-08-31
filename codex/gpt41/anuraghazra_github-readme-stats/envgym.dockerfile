# Node.js 22 base image, bash shell, repo installed
FROM node:22

# Set working directory to /app (repo root in container)
WORKDIR /app

# Copy the repo contents into the container
COPY . /app

# Install dependencies
RUN npm install

# Default to bash in repo root
CMD ["/bin/bash"]
