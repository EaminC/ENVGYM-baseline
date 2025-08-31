FROM node:latest

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package.json package-lock.json ./
RUN npm install

# Bundle app source
COPY . .

# Set default command to bash shell
CMD ["/bin/bash"]
