FROM ubuntu:20.04

# Install dependencies including build tools and SSL
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    libssl-dev \
    zlib1g-dev \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to /app
WORKDIR /app

# Copy entire build context
COPY . .

# Generate SSL certificates if missing
RUN if [ ! -f ssl/cert.pem ]; then \
    mkdir -p ssl && \
    openssl req -x509 -newkey rsa:4096 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -days 365 -nodes -subj "/CN=localhost"; \
    fi

# Configure and build project
RUN mkdir -p build && \
    cd build && \
    cmake .. && \
    make

# Set default command to bash at repository root
WORKDIR /app
CMD ["/bin/bash"]