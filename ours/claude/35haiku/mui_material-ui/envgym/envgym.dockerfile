FROM debian:bullseye-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    npm \
    git \
    curl \
    bash

COPY . .

RUN npm ci

RUN npm run build

EXPOSE 3000

CMD ["/bin/bash"]