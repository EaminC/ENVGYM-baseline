FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y build-essential cmake python3 git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /simdjson

COPY . /simdjson

RUN mkdir -p build && cd build && \
    cmake -D SIMDJSON_DEVELOPER_MODE=ON .. && \
    cmake --build .

WORKDIR /simdjson

CMD ["/bin/bash"]
