FROM golang:1.21.13-alpine AS builder

RUN apk add --no-cache \
    git \
    make \
    curl \
    bash \
    tzdata \
    upx \
    protoc \
    protobuf-dev \
    build-base \
    openssh-client \
    gpg \
    gpg-agent

ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on
ENV CGO_ENABLED=0

# Install critical tools first
RUN go install github.com/zeromicro/go-zero/tools/goctl@v1.8.4-beta
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.5
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.20.0
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.20.0
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN go install go.uber.org/mock/mockgen@v0.4.0

FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    git \
    make \
    curl \
    tzdata \
    ca-certificates \
    openssh-client \
    docker \
    docker-compose \
    kubectl \
    helm \
    python3 \
    py3-pip \
    nodejs \
    npm \
    jq \
    yq \
    gpg \
    gpg-agent \
    github-cli \
    protoc \
    protobuf-dev \
    mysql-client \
    postgresql-client \
    mongodb-tools \
    redis \
    prometheus \
    grafana \
    vim \
    nano

RUN npm install -g @withfig/autocomplete

COPY --from=builder /go/bin/* /usr/local/bin/
COPY --from=builder /usr/local/go /usr/local/go

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on

WORKDIR /home/cc/EnvGym/data/zeromicro_go-zero

COPY . .

RUN go mod download || true

CMD ["/bin/bash"]