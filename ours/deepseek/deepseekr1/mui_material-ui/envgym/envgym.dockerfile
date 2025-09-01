FROM node:18-alpine

RUN apk add --no-cache bash

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 1000000

COPY . .
RUN yarn build --max-old-space-size=4096

EXPOSE 3000

CMD ["bash"]