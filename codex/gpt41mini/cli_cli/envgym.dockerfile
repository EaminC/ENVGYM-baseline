FROM golang:1.24

WORKDIR /app

# Copy all source code
COPY . .

# Download dependencies
RUN go mod download

# Build the binary
RUN go run script/build.go bin/gh

# Start bash shell in container
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "cd /app && exec /bin/bash"]
