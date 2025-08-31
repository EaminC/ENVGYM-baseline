FROM golang:1.24

# Set working directory in container
WORKDIR /go/src/google.golang.org/grpc

# Install git for dependency management
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Copy module files first for caching
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy entire source
COPY . .

# Build all packages
RUN go build ./...

# Start container with bash shell
CMD ["/bin/bash"]
