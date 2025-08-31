FROM node:18

WORKDIR /app

# Copy all files to /app in container
COPY . .

# Install npm dependencies
RUN npm install

# Start with bash shell in interactive mode
CMD ["/bin/bash"]
