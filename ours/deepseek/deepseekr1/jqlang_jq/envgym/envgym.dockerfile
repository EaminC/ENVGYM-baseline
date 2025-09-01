FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    automake \
    autoconf \
    libtool \
    bison \
    flex \
    pkg-config \
    python3 \
    python3-pip \
    valgrind \
    rpm \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pipenv

RUN git clone https://github.com/jqlang/jq.git /jq
WORKDIR /jq

RUN git submodule update --init

WORKDIR /jq/docs
RUN pipenv sync

WORKDIR /jq/vendor/decNumber
RUN gcc -O3 -o example1 example1.c decNumber.c decContext.c && \
    ./example1 1.23 1.27 | grep "2.50"

WORKDIR /jq
RUN autoreconf -i
RUN ./configure --with-oniguruma=builtin --enable-docs
RUN make -j$(nproc)
RUN make check 2>&1 | tee make_check.log || (cat tests/test-suite.log make_check.log && false)
RUN make install
RUN ldconfig
RUN man -w jq >/dev/null && echo "Manpage verified"

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
RUN pkg-config --libs --cflags libjq && \
    echo -e '#include <jq.h>\n#include <stdio.h>\nint main() { jq_state *jq = jq_init(); if(jq) { printf("libjq initialized\\n"); jq_teardown(&jq); return 0; } else { return 1; } }' > test_libjq.c && \
    gcc test_libjq.c -o test_libjq $(pkg-config --libs --cflags libjq) && \
    ./test_libjq && \
    rm test_libjq test_libjq.c

WORKDIR /jq/docs
RUN pipenv run python3 build_website.py

WORKDIR /jq
RUN make rpm && rpm -qlp ./jq-*.rpm

RUN mkdir -p /home/cc/EnvGym/data/jqlang_jq && \
    echo '{"test":1234}' > /home/cc/EnvGym/data/jqlang_jq/test.json

WORKDIR /jq
CMD ["bash"]