FROM node:16-alpine AS builder

ARG WORKDIR=/home/cc/EnvGym/data-gpt-4.1mini/iamkun_dayjs
WORKDIR ${WORKDIR}

RUN apk add --no-cache git bash python3 build-base gcc g++ make

COPY package.json package-lock.json ./
RUN npm cache clean --force && \
    npm install --legacy-peer-deps --force && \
    npm install rollup --force

COPY . .
RUN npm install --legacy-peer-deps --force && \
    npm run build || (cat npm-debug.log && exit 1)

FROM node:16-alpine

ARG WORKDIR=/home/cc/EnvGym/data-gpt-4.1mini/iamkun_dayjs
WORKDIR ${WORKDIR}

RUN apk add --no-cache bash git

COPY --from=builder ${WORKDIR} .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

VOLUME ["/home/cc/EnvGym/data-gpt-4.1mini/iamkun_dayjs"]

CMD ["/bin/bash"]