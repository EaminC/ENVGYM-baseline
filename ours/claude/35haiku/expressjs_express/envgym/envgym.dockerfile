FROM node:18-alpine3.18 AS builder

WORKDIR /app

COPY package.json ./
RUN npm install

FROM node:18-alpine3.18

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app

COPY --from=builder /app/node_modules ./node_modules
COPY . .

RUN chown -R appuser:appgroup /app

USER root

COPY index.js ./

EXPOSE 3000

CMD ["/bin/sh"]