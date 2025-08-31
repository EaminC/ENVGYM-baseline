# Use official Node LTS image
FROM node:20

# Set working directory to repo root
WORKDIR /repo

# Copy all files
COPY . /repo

# Install dependencies
RUN npm install

# (Optional) Build distribution files if needed
RUN npm run build || true

# Default to /bin/bash at repo root
CMD ["/bin/bash"]
