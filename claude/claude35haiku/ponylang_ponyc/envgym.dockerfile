# Dockerfile for Pony Language Compiler Development Environment
FROM ubuntu:24.04

# Install dependencies based on BUILD.md requirements
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    make \
    git \
    python3 \
    binutils-gold \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /ponyc

# Clone the repository (note: in real use, you'd want to mount the local repo)
RUN git clone https://github.com/ponylang/ponyc.git .

# Build ponyc 
RUN make libs && \
    make configure && \
    make build

# Create entrypoint script to handle interactive mode
RUN echo '#!/bin/bash\n\
cd /ponyc\n\
exec /bin/bash' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint to an interactive bash shell
ENTRYPOINT ["/entrypoint.sh"]