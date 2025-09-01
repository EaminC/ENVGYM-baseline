FROM golang:1.25
ARG PARALLELISM=96

RUN apt-get update && apt-get install -y protobuf-compiler

WORKDIR /app
COPY . .

RUN go mod tidy -go=1.25
RUN go mod vendor -v
RUN cd examples && go mod tidy -go=1.25 -compat=1.25 && go mod vendor -v
RUN cd gcp/observability && go mod tidy -go=1.25 && go mod verify

RUN find . -name go.mod -execdir sh -c 'go mod vendor -v' \;

RUN go install github.com/mgechev/revive@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@latest \
    && go install -v google.golang.org/protobuf/cmd/protoc-gen-go@latest \
    && go install -v -buildvcs=false google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

RUN go build -v -p=${PARALLELISM} ./...
RUN cd examples && go build -v -p=${PARALLELISM} ./...

CMD ["/bin/bash"]