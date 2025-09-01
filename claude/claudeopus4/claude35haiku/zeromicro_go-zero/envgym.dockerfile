FROM golang:1.21-bullseye

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the entire repository
COPY . .

# Install dependencies
RUN go mod download

# Build the project
RUN go build -o go-zero ./

# Set up entrypoint to start a bash shell
ENTRYPOINT ["/bin/bash"]