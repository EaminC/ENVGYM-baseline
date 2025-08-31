# syntax=docker/dockerfile:1
FROM golang:1.21-bullseye

# Create a workspace directory and set as working dir
WORKDIR /workspace

# Copy the repository contents into the container
COPY . /workspace

# Download Go module dependencies
RUN go mod download

# Optional: Build repo to check everything is okay
# RUN make build

# Default to bash CLI in the repo root
CMD ["/bin/bash"]
