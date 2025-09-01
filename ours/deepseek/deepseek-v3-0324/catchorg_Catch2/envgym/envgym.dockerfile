FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    g++-9 \
    cmake \
    meson \
    git \
    python3 \
    python3-pip \
    ninja-build \
    doxygen \
    graphviz \
    gdb \
    pkg-config \
    valgrind \
    gpg \
    wget \
    curl \
    unzip \
    tar \
    software-properties-common \
    libxml2-utils \
    libxslt1-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-9 g++-9 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90

RUN wget -O /tmp/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-amd64 && \
    chmod +x /tmp/bazelisk && \
    mv /tmp/bazelisk /usr/local/bin/bazel

RUN for version in 6.0 7 8 9 10 11 12 13 14; do \
    apt-get install -y clang-$version llvm-$version; \
    done

RUN apt-get install -y clang-15 clang-tidy-15

RUN pip install conan==1.53.0 && \
    pip install conan==2.1 && \
    pip install guardonce && \
    pip install junit-xml && \
    pip install MathJax

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    zip \
    unzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg && \
    cd /opt/vcpkg && \
    git checkout 2023.08.09 && \
    ./bootstrap-vcpkg.sh -disableMetrics && \
    ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg

RUN wget -O /tmp/gh-cli.deb https://github.com/cli/cli/releases/download/v2.32.1/gh_2.32.1_linux_amd64.deb && \
    dpkg -i /tmp/gh-cli.deb && \
    rm /tmp/gh-cli.deb

RUN git clone https://github.com/catchorg/Catch2.git /tmp/catch2 && \
    cd /tmp/catch2 && \
    git checkout v3.10.0 && \
    cmake -Bbuild -H. -DBUILD_TESTING=OFF && \
    cmake --build build/ --target install && \
    rm -rf /tmp/catch2

WORKDIR /repo
COPY . /repo

RUN mkdir -p /repo/build && \
    cd /repo/build && \
    cmake .. && \
    cmake --build .

CMD ["/bin/bash"]