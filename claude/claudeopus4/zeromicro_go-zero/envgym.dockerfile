# envgym.dockerfile - Development environment for go-zero
FROM golang:1.21-alpine

# Install essential tools and dependencies
RUN apk add --no-cache \
    git \
    bash \
    build-base \
    curl \
    vim \
    tree \
    make \
    && rm -rf /var/cache/apk/*

# Set working directory to repository root
WORKDIR /go-zero

# Copy the entire repository
COPY . .

# Download Go dependencies
RUN go mod download

# Build goctl tool if it exists
RUN if [ -d "tools/goctl" ]; then \
        cd tools/goctl && go build -o /usr/local/bin/goctl .; \
    fi

# Set bash as default shell and start at repository root
SHELL ["/bin/bash", "-c"]

# Default command starts bash shell at repository root
CMD ["/bin/bash"]