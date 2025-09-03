FROM ubuntu:22.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    wget \
    gnupg \
    lsb-release \
    && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
    && echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/kitware.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    cmake \
    ninja-build \
    meson \
    python3 \
    python3-dev \
    python3-pip \
    zlib1g-dev \
    liblzma-dev \
    liblz4-dev \
    git \
    && git clone https://github.com/google/googletest.git /googletest \
    && cd /googletest \
    && cmake -B build -S . -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel \
    && cmake --install build

WORKDIR /project

COPY . .

RUN cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DZSTD_BUILD_TESTS=OFF \
    -DZSTD_BUILD_CONTRIB=OFF \
    -DZSTD_BUILD_PROGRAMS=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_C_FLAGS="-Wno-error -Wno-deprecated-declarations -Wno-stringop-overflow -Wno-restrict -Wno-unused-parameter -w" \
    -DCMAKE_CXX_FLAGS="-Wno-error -Wno-deprecated-declarations -Wno-stringop-overflow -Wno-restrict -Wno-unused-parameter -w" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && cmake --build build --verbose --parallel 1 \
    && cmake --install build

FROM ubuntu:22.04

COPY --from=builder /project /project
COPY --from=builder /usr/local /usr/local

WORKDIR /project

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    zlib1g \
    liblzma-dev \
    liblz4-1 \
    && ldconfig \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/project/build/programs:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

CMD ["/bin/bash"]