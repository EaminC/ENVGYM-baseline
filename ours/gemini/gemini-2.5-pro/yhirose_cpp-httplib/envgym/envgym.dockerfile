# Stage 1: Builder/Development Environment
FROM ubuntu:22.04 AS builder

# Set non-interactive frontend for package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install all dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core build tools
    build-essential \
    git \
    cmake \
    meson \
    ninja-build \
    make \
    pkg-config \
    # Language toolchains
    python3 \
    python3-pip \
    golang-go \
    # Library dependencies
    openssl \
    libssl-dev \
    zlib1g-dev \
    libbrotli-dev \
    libzstd-dev \
    libcurl4-openssl-dev \
    libanl-dev \
    # Testing and utility tools
    clang-format \
    qemu-user-static \
    apache2-utils \
    netcat-openbsd \
    abigail-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure Go environment and install Go-based tools
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go install github.com/codesenberg/bombardier@latest
RUN go install github.com/nakabonne/ali@latest

# Install Python-based tools
RUN pip3 install pre-commit

# Set up the working directory
WORKDIR /home/cc/EnvGym/data/yhirose_cpp-httplib

# Copy the project source code into the container
COPY . .

# Create password files required for proxy tests
RUN htpasswd -cb test/proxy/passwd testuser testpass && \
    (echo testpass; echo testpass) | htdigest -c test/proxy/passwd_digest proxy testuser

# Install git pre-commit hooks
RUN pre-commit install

# Set git safe directory to avoid ownership issues inside the container
RUN git config --global --add safe.directory /home/cc/EnvGym/data/yhirose_cpp-httplib

# Compile the application binary for the production image
RUN g++ -std=c++11 -o /app/server docker/main.cc -I. -pthread -lssl -lcrypto

# Stage 2: Minimal Production Image
FROM gcr.io/distroless/cc-debian11

# Set the working directory for the application
WORKDIR /app

# Copy the compiled application binary from the builder stage
COPY --from=builder /app/server /app/server

# Copy the static HTML assets from the builder stage
COPY --from=builder /home/cc/EnvGym/data/yhirose_cpp-httplib/docker/html /app/html

# Expose the port the server will listen on
EXPOSE 8080

# Set the command to run the application
CMD ["/app/server"]