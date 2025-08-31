FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy all files to /app
COPY . /app

# Build and install the library
RUN mkdir -p build && cd build && \ 
    cmake -DCMAKE_BUILD_TYPE=Release .. && \ 
    cmake --build . --target install

WORKDIR /app

CMD ["/bin/bash"]
