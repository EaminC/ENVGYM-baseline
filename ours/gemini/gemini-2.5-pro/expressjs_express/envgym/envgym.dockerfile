# Stage 1: Build wrk using a Debian-based image for better compatibility
FROM debian:bullseye-slim AS builder

# Install build dependencies for wrk, including git for submodules
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    make \
    gcc \
    libssl-dev \
    zlib1g-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and compile wrk from source tarball
ARG WRK_VERSION=4.2.0
RUN curl -L -o /tmp/wrk.tar.gz https://github.com/wg/wrk/archive/refs/tags/${WRK_VERSION}.tar.gz && \
    tar -xzvf /tmp/wrk.tar.gz -C /tmp && \
    cd /tmp/wrk-${WRK_VERSION} && \
    make

# Stage 2: Final application image
FROM node:20-alpine

# Set the working directory for the project
WORKDIR /home/cc/EnvGym/data/expressjs_express

# Install system dependencies:
# - bash: for the final interactive shell
# - git, python3, make, g++: core build tools for npm modules
# - lcov: for test coverage report merging
RUN apk update && apk add --no-cache \
    bash \
    git \
    python3 \
    make \
    g++ \
    lcov

# Copy the compiled wrk binary from the builder stage
ARG WRK_VERSION=4.2.0
COPY --from=builder /tmp/wrk-${WRK_VERSION}/wrk /usr/local/bin/

# Copy package.json to leverage Docker cache
COPY package.json .

# Create the .npmrc file to prevent package-lock.json generation, as per project policy
RUN echo "package-lock=false" > .npmrc

# Install all project dependencies (runtime and development)
RUN npm install

# Copy the rest of the application source code into the container
COPY . .

# Set the default command to start a bash shell in the working directory
CMD ["/bin/bash"]