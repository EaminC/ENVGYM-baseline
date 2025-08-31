FROM golang:1.21

WORKDIR /go-zero

COPY . .

RUN go mod download

CMD ["/bin/bash"]
