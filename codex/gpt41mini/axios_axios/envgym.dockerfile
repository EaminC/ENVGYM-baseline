FROM node:18

WORKDIR /app

# Copy package files first for caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the repository
COPY . .

CMD ["/bin/bash"]
