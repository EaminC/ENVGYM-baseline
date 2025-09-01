FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /home/cc/EnvGym
WORKDIR $HOME/data/fmtlib_fmt

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    doxygen \
    pkg-config \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install mkdocs

# Clone fmt repository
RUN git clone https://github.com/fmtlib/fmt.git . && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

# Build and install fmt
RUN mkdir build && \
    cd build && \
    cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DFMT_TEST=ON .. && \
    ninja && \
    ninja test && \
    ninja install && \
    cd .. && \
    rm -rf build

WORKDIR /

CMD ["/bin/bash"]