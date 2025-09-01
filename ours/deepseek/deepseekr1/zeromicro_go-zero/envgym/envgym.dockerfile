FROM golang:latest

RUN mkdir -p /home/cc/EnvGym/data/zeromicro_go-zero
WORKDIR /home/cc/EnvGym/data/zeromicro_go-zero
COPY . .

RUN go mod download

CMD ["/bin/bash"]