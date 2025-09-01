FROM golang:1.21-bullseye

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /gh-cli

# Copy the entire repository 
COPY . .

# Build the CLI
RUN make bin/gh

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]