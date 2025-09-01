FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

RUN apt update && apt install -y locales && \
    locale-gen de_DE.UTF-8 && \
    update-locale LANG=de_DE.UTF-8

RUN apt update && apt install -y \
    build-essential \
    unzip \
    wget \
    libssl-dev \
    clang-tools \
    iwyu \
    gcc-multilib \
    g++-multilib \
    valgrind \
    lcov \
    gdb \
    p7zip-full \
    cmake \
    ninja-build \
    git \
    python3-pip \
    python3 \
    afl \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

RUN git clone https://github.com/nlohmann/json.git

WORKDIR /workspace/json

RUN pip3 install -r docs/mkdocs/requirements.txt
RUN pip3 install -r tools/astyle/requirements.txt
RUN pip3 install -r tools/generate_natvis/requirements.txt
RUN pip3 install -r tools/serve_header/requirements.txt
RUN pip3 install -r cmake/requirements/requirements-cppcheck.txt
RUN pip3 install -r cmake/requirements/requirements-cpplint.txt
RUN pip3 install -r cmake/requirements/requirements-reuse.txt

RUN wget https://github.com/github/codeql-cli-binaries/releases/download/v2.14.6/codeql-linux64.zip && \
    unzip codeql-linux64.zip -d /opt && \
    rm codeql-linux64.zip
ENV PATH="/opt/codeql:${PATH}"

RUN git clone https://github.com/emscripten-core/emsdk.git /workspace/emsdk
WORKDIR /workspace/emsdk
RUN ./emsdk install latest && \
    ./emsdk activate latest
ENV EMSDK=/workspace/emsdk
ENV PATH="/workspace/emsdk:/workspace/emsdk/upstream/emscripten:/workspace/emsdk/node/14.18.2_64bit/bin:${PATH}"

RUN echo "source /workspace/json/tools/gdb_pretty_printer/nlohmann-json.py" >> ~/.gdbinit

WORKDIR /workspace/json
CMD ["/bin/bash"]