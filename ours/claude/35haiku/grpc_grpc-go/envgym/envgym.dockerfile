FROM golang:1.21-alpine3.19 AS builder

RUN apk add --no-cache \
    git \
    make \
    protoc \
    protobuf-dev \
    gcc \
    musl-dev \
    curl

ENV GO111MODULE=on \
    GOPATH=/go \
    PATH=$PATH:/go/bin \
    GOPROXY=https://proxy.golang.org,direct \
    GO_NET_TIMEOUT=300s \
    CGO_ENABLED=1 \
    GOPRIVATE=* \
    GOSUMDB=off

WORKDIR /app

COPY go.mod go.sum ./

RUN mkdir -p /go/pkg/mod/cache && \
    go mod tidy && \
    go mod download -v && \
    go mod verify || true

COPY . .

RUN cd cmd/protoc-gen-go-grpc && \
    go build -v \
    -ldflags="-s -w" \
    -o /bin/protoc-gen-go-grpc \
    main.go \
    && echo "Build completed successfully" \
    || (echo "Build failed with error" && exit 1)

FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    ca-certificates \
    git \
    curl \
    wget \
    protoc \
    go

COPY --from=builder /bin/protoc-gen-go-grpc /bin/protoc-gen-go-grpc
COPY --from=builder /app /workspace

WORKDIR /workspace

ENV GOROOT=/usr/lib/go \
    GOPATH=/go \
    PATH=$PATH:/usr/lib/go/bin:/go/bin

RUN go mod download && \
    go mod verify && \
    go install ./cmd/protoc-gen-go-grpc

ENTRYPOINT ["/bin/bash"]

CMD ["-c", "exec /bin/bash"]