FROM ubuntu:latest

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    make \
    gcc \
    zlib1g-dev \
    liblzma-dev

# Set working directory
WORKDIR /zstd

# Copy the entire repository
COPY . .

# Build zstd 
RUN make

# Set the default command to bash
CMD ["/bin/bash"]