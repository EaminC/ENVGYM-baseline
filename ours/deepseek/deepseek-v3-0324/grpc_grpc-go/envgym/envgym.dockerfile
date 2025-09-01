FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/cc \
    GOPATH=/go \
    PATH=/usr/local/go/bin:/go/bin:$PATH \
    WORKDIR=/home/cc/grpc_grpc-go

RUN useradd -m -u 1000 -s /bin/bash cc && \
    mkdir -p $WORKDIR && \
    chown cc:cc $WORKDIR

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libssl-dev \
    openssl \
    pkg-config \
    protobuf-compiler \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

COPY --chown=cc:cc . $WORKDIR/

WORKDIR $WORKDIR

RUN mkdir -p $WORKDIR/security/advancedtls/testdata && \
    chmod 755 $WORKDIR/security/advancedtls/testdata

USER cc

ENTRYPOINT ["/bin/bash"]