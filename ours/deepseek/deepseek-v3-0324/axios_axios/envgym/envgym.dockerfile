FROM node:16-alpine

WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
COPY tsconfig.json .
COPY rollup.config.js .

RUN apk add --no-cache git python3 make g++ bash

RUN npm ci --ignore-scripts --omit=dev

COPY lib lib
COPY bin bin
COPY dist dist
COPY examples examples
COPY sandbox sandbox
COPY templates templates
COPY test test

RUN npm install typescript@4.9.5 eslint@8.56.0 rollup@2.79.1 --save-dev
RUN npm pkg delete scripts.prepare || true
RUN npm pkg delete scripts.prepare:hooks || true
RUN npm run build || (echo "Build failed but continuing" && exit 0)

CMD ["/bin/bash"]