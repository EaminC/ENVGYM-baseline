FROM golang:1.21-bullseye
LABEL maintainer="envgym"

# Set shell and working directory
SHELL ["/bin/bash", "-c"]
WORKDIR /repo

# Copy everything
COPY . /repo

# Install dependencies
RUN go mod download

# Set entrypoint to bash shell
ENTRYPOINT ["/bin/bash"]
