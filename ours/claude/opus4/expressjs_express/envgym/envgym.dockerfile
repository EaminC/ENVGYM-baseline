FROM node:18-alpine

RUN apk add --no-cache \
    bash \
    git \
    make \
    build-base \
    redis \
    lcov \
    yamllint \
    gcc \
    musl-dev \
    openssl-dev \
    curl \
    wget \
    linux-headers \
    npm

RUN wget https://github.com/wg/wrk/archive/refs/tags/4.2.0.tar.gz -O /tmp/wrk.tar.gz && \
    cd /tmp && tar -xzf wrk.tar.gz && \
    cd wrk-4.2.0 && \
    make && \
    cp wrk /usr/local/bin/ && \
    cd / && rm -rf /tmp/wrk*

RUN npm install -g n

RUN n 16 && n 17 && n 18

WORKDIR /home/cc/EnvGym/data/expressjs_express

COPY . .

RUN if [ -f package.json ]; then npm install; fi

RUN chmod -R 755 /home/cc/EnvGym/data/expressjs_express

RUN redis-server --daemonize yes

CMD ["/bin/bash"]