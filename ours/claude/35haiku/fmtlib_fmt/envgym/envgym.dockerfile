FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# Core system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    software-properties-common \
    wget \
    curl \
    git \
    unzip \
    python3 \
    python3-pip \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    doxygen

# Install GCC 13
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-13 g++-13 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-13

# Install Clang 14
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 14 && \
    rm llvm.sh

# Install Bazel with retry and curl
RUN set -e && \
    max_retries=3 && \
    retry_count=0 && \
    while [ $retry_count -lt $max_retries ]; do \
        curl -L https://github.com/bazelbuild/bazelisk/releases/download/v1.16.1/bazelisk-linux-amd64 -o /usr/local/bin/bazel && \
        chmod +x /usr/local/bin/bazel && \
        break || \
        retry_count=$((retry_count+1)) && \
        sleep 5; \
    done

# Python documentation tools
RUN pip3 install \
    mkdocs \
    mkdocs-material \
    pymdown-extensions \
    mkdocstrings \
    virtualenv

# Install Docker BuildKit tools
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Clone and prepare repository
RUN git clone https://github.com/fmtlib/fmt.git /workspace/fmt

# Set working directory
WORKDIR /workspace/fmt

# Configure and build project
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build

# Default command
CMD ["/bin/bash"]