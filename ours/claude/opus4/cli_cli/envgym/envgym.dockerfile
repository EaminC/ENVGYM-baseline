FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git make bash

WORKDIR /workspace

COPY . .

RUN if [ -f go.mod ]; then \
        echo "go.mod found, downloading dependencies..." && \
        go mod download; \
    elif [ -n "$(find . -name '*.go' -print -quit)" ]; then \
        echo "Go files found but no go.mod, initializing module..." && \
        go mod init github.com/cli/cli && \
        go mod tidy; \
    else \
        echo "No Go files found, skipping module initialization"; \
    fi

RUN ls -la && \
    echo "Contents of cmd directory:" && \
    ls -la cmd/ && \
    echo "Contents of cmd/gh directory:" && \
    ls -la cmd/gh/ && \
    if [ -f Makefile ]; then \
        echo "Building with Makefile..." && \
        make; \
    elif [ -f cmd/gh/main.go ]; then \
        echo "Building with go build..." && \
        mkdir -p bin && \
        go build -v -o bin/gh ./cmd/gh; \
    else \
        echo "No buildable Go files found"; \
    fi

FROM alpine:latest

RUN apk add --no-cache bash git ca-certificates

COPY --from=builder /workspace/bin/gh /usr/local/bin/gh

WORKDIR /workspace
COPY . .

ENTRYPOINT ["/bin/bash"]