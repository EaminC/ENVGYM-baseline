FROM debian:12-slim AS build

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    ARCH=x86_64

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    clang \
    llvm \
    git \
    wget \
    python3 \
    python3-pip \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

RUN mkdir -p build && \
    cd build && \
    cmake -G Ninja \
          -DCMAKE_BUILD_TYPE=Release \
          -DSIMDJSON_BUILD_STATIC=ON \
          -DSIMDJSON_EXCEPTIONS=ON \
          -DSIMDJSON_SANITIZE=OFF \
          .. 2>&1 | tee cmake.log && \
    ninja 2>&1 | tee build.log && \
    ninja install 2>&1 | tee install.log

FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY --from=build /workspace /workspace

ENTRYPOINT ["/bin/bash"]