# Use Go 1.24 official slim image
FROM golang:1.24-slim

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
 && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /src

# Copy the repository
COPY . /src

# Build and install gh
RUN make bin/gh
RUN make install DESTDIR=/usr/local prefix=""

# Put bin directory in PATH
ENV PATH="/usr/local/bin:$PATH"

# Set entrypoint to interactive shell
ENTRYPOINT ["/bin/bash"]
