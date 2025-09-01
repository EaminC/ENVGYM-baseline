FROM alpine:3.18 AS builder

RUN apk add --no-cache \
    git \
    cmake \
    make \
    g++ \
    openssl-dev \
    zlib-dev \
    brotli-dev \
    zstd-dev \
    meson \
    pkgconfig \
    python3 \
    bash

WORKDIR /src
COPY . /src/cpp-httplib
WORKDIR /src/cpp-httplib/build

RUN cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DHTTPLIB_COMPILE=ON ..
RUN make
RUN make install

FROM alpine:3.18

RUN apk add --no-cache \
    openssl \
    zlib \
    brotli \
    zstd \
    libstdc++ \
    libgcc \
    bash

COPY --from=builder /usr/local/include/httplib.h /usr/local/include/
COPY --from=builder /src/cpp-httplib /app

WORKDIR /app
CMD ["/bin/bash"]