FROM node:14-alpine

WORKDIR /home/cc/EnvGym/data/iamkun_dayjs

RUN apk update && \
    apk add --no-cache \
    git \
    chromium \
    bash

COPY package.json .
COPY package-lock.json .

RUN npm install && \
    npm install -g \
    @babel/core \
    @babel/cli \
    @babel/node \
    jest \
    eslint \
    prettier \
    typescript \
    rollup \
    cross-env \
    karma \
    karma-chrome-launcher \
    karma-jasmine \
    karma-coverage

COPY . .

ENV CHROME_BIN=/usr/bin/chromium-browser

CMD ["/bin/bash"]