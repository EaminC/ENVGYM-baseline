FROM golang:1.24-alpine

# Install required tools
RUN apk add --no-cache \
    git \
    bash \
    make \
    curl \
    protobuf \
    protobuf-dev

# Install Go protoc plugins
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
    go install github.com/envoyproxy/protoc-gen-validate@latest

# Install gRPCurl
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Set working directory
WORKDIR /workspace

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire repository
COPY . .

# Set Go environment variables
ENV GO111MODULE=on
ENV GOPROXY=https://proxy.golang.org,direct
ENV PATH=$PATH:/go/bin

# Default to bash shell
CMD ["/bin/bash"]