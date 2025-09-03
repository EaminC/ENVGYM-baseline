FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-9 \
    g++-9 \
    clang-10 \
    git \
    wget \
    curl \
    python3.8 \
    python3-pip \
    ninja-build \
    clang-format \
    valgrind \
    graphviz \
    pkg-config \
    openmpi-bin \
    software-properties-common \
    gnupg \
    lsb-release \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 100

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update \
    && apt-get install -y cmake \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" \
    && apt-get update \
    && apt-get install -y clang-tidy-15 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip \
    && pip3 install meson==0.64.0 \
    && pip3 install conan==1.63.0 \
    && pip3 install conan==2.1.0 --force-reinstall \
    && pip3 install conan_package_tools \
    && pip3 install codecov

RUN wget https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel-7.0.0-linux-x86_64 -O /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel

RUN wget https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 -O /usr/local/bin/bazelisk \
    && chmod +x /usr/local/bin/bazelisk

RUN wget https://github.com/doxygen/doxygen/releases/download/Release_1_9_8/doxygen-1.9.8.linux.bin.tar.gz \
    && tar -xzf doxygen-1.9.8.linux.bin.tar.gz \
    && cd doxygen-1.9.8 \
    && make install \
    && cd .. \
    && rm -rf doxygen-1.9.8*

RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-6.0 \
    && rm -rf /var/lib/apt/lists/*

RUN dotnet --version && dotnet tool install -g MarkdownSnippets.Tool || echo "MarkdownSnippets.Tool installation failed, continuing..."

ENV PATH="/root/.dotnet/tools:${PATH}"

WORKDIR /home/cc/EnvGym/data/catchorg_Catch2

COPY . .

RUN mkdir -p build builddir docs/doxygen

RUN echo "7.0.0" > .bazelversion

WORKDIR /home/cc/EnvGym/data/catchorg_Catch2

CMD ["/bin/bash"]