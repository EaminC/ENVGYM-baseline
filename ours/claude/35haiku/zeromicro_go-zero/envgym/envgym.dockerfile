FROM golang:1.21-alpine AS builder

ARG TARGETPLATFORM=linux/amd64
ARG GOPROXY=https://goproxy.cn,direct

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPROXY=${GOPROXY}

WORKDIR /app

RUN apk add --no-cache \
    git \
    curl \
    protoc \
    protobuf-dev \
    build-base

COPY . .

RUN cd tools/goctl \
    && go clean -modcache \
    && go mod tidy -v \
    && go mod download -v \
    && GOWORK=off go build -v -o /usr/local/bin/goctl goctl.go \
    && cd /app \
    && go clean -modcache \
    && go mod tidy -v \
    && go mod download -v \
    && go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest || true

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache \
    bash \
    ca-certificates \
    git \
    curl \
    protoc \
    protobuf-dev \
    go

COPY --from=builder /app /app
COPY --from=builder /go/bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=builder /usr/local/bin/goctl /usr/local/bin/goctl

RUN mkdir -p /app/mcp /app/gateway /app/tools /app/config /app/tests \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app

USER appuser

WORKDIR /app

EXPOSE 8080

CMD ["/bin/bash"]