FROM golang:1.23-alpine AS builder

RUN apk add --no-cache \
    git \
    make \
    curl \
    wget \
    tar \
    gcc \
    musl-dev \
    linux-headers \
    openssl-dev \
    bash \
    docker-cli \
    mysql-client \
    postgresql-client \
    mongodb-tools \
    redis \
    protobuf \
    protobuf-dev

WORKDIR /workspace
COPY . .

RUN wget https://github.com/actions/runner/releases/download/v2.315.0/actions-runner-linux-x64-2.315.0.tar.gz -O actions-runner.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz

RUN wget https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-linux-amd64 -O /usr/local/bin/kind \
    && chmod +x /usr/local/bin/kind

RUN wget https://github.com/etcd-io/etcd/releases/download/v3.5.10/etcd-v3.5.10-linux-amd64.tar.gz -O etcd.tar.gz \
    && tar xzf etcd.tar.gz --strip-components=1 -C /usr/local/bin etcd-v3.5.10-linux-amd64/etcd etcd-v3.5.10-linux-amd64/etcdctl \
    && rm etcd.tar.gz

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protoc-3.20.3-linux-x86_64.zip -O protoc.zip \
    && unzip protoc.zip -d /usr/local \
    && rm protoc.zip

RUN go install github.com/zeromicro/go-zero/tools/goctl@latest
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
RUN GO111MODULE=on go install github.com/securego/gosec/v2/cmd/gosec@v2.15.0

FROM alpine:latest

RUN apk add --no-cache \
    bash \
    git \
    curl \
    docker-cli \
    mysql-client \
    postgresql-client \
    mongodb-tools \
    redis \
    protobuf \
    libc6-compat

COPY --from=builder /workspace /workspace
COPY --from=builder /go/bin/goctl /usr/local/bin/goctl
COPY --from=builder /go/bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=builder /go/bin/gosec /usr/local/bin/gosec
COPY --from=builder /usr/local/bin/kind /usr/local/bin/kind
COPY --from=builder /usr/local/bin/etcd* /usr/local/bin/
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/bin/protoc /usr/local/bin/protoc

WORKDIR /workspace
ENV PATH="/workspace/bin:/usr/local/go/bin:${PATH}"

CMD ["/bin/bash"]