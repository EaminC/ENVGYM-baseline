FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy repository contents
COPY . /app

# Build the project
RUN mkdir build && cd build && cmake .. && cmake --build .

# Start with bash shell in the repo root
CMD ["/bin/bash"]
