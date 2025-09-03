FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    make \
    pkg-config \
    libssl-dev \
    locales \
    gcc-multilib \
    g++-multilib \
    python3 \
    python3-pip \
    python3-venv \
    ninja-build \
    lcov \
    valgrind \
    doxygen \
    clang \
    clang-tools \
    libc++-dev \
    libc++abi-dev \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get update && \
    apt-get install -y cmake && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel

RUN pip3 install \
    meson==1.3.0 \
    PyYAML==6.0.2 \
    watchdog==6.0.0 \
    jinja2==3.1.6 \
    MkDocs==1.6.1 \
    mkdocs-git-revision-date-localized-plugin==1.4.7 \
    mkdocs-material==9.6.18 \
    mkdocs-material-extensions==1.3.1 \
    mkdocs-minify-plugin==0.8.0 \
    mkdocs-redirects==1.2.2 \
    mkdocs-htmlproofer-plugin==1.3.0 \
    cppcheck==1.5.0 \
    cpplint==2.0.2 \
    reuse==5.0.2 \
    astyle==3.4.13 \
    coveralls

RUN wget https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

RUN git clone https://github.com/emscripten-core/emsdk.git /opt/emsdk && \
    cd /opt/emsdk && \
    ./emsdk install latest && \
    ./emsdk activate latest

ENV PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:${PATH}"

RUN wget https://swift.org/builds/swift-5.9.2-release/ubuntu2204/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-ubuntu22.04.tar.gz && \
    tar xzf swift-5.9.2-RELEASE-ubuntu22.04.tar.gz && \
    mv swift-5.9.2-RELEASE-ubuntu22.04 /opt/swift && \
    rm swift-5.9.2-RELEASE-ubuntu22.04.tar.gz

ENV PATH="/opt/swift/usr/bin:${PATH}"

RUN git clone https://github.com/google/benchmark.git /opt/benchmark && \
    cd /opt/benchmark && \
    cmake -E make_directory "build" && \
    cmake -E chdir "build" cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build "build" --config Release && \
    cmake --install "build" --config Release

WORKDIR /workspace

COPY . /workspace/

RUN cd /workspace && \
    mkdir -p build && \
    cd build && \
    cmake .. -DJSON_BuildTests=ON && \
    make -j$(nproc)

CMD ["/bin/bash"]