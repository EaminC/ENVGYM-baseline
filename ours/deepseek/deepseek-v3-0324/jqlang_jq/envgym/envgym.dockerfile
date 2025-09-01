FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libtool \
    make \
    automake \
    autoconf \
    flex \
    bison \
    python3 \
    python3-dev \
    python3-pip \
    pkg-config \
    liblz4-dev \
    valgrind \
    rpm \
    gcovr \
    libasan6 \
    libubsan1 \
    wget \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

COPY vendor/decNumber /root/vendor/decNumber

RUN cd vendor/decNumber && \
    gcc -m64 -O3 -c decNumber.c decContext.c && \
    ar rcs libdecnumber.a decNumber.o decContext.o && \
    mkdir -p /usr/local/lib /usr/local/include && \
    cp libdecnumber.a /usr/local/lib/ && \
    cp decNumber.h decContext.h /usr/local/include/ && \
    ldconfig

COPY . /root/

RUN autoreconf -fi && \
    ./configure --host=x86_64-linux-gnu && \
    make -j$(nproc) && \
    make install

CMD ["/bin/bash"]