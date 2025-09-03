FROM node:alpine

RUN apk add --no-cache \
    git \
    bash \
    python3 \
    make \
    g++ \
    curl \
    openssh-client

WORKDIR /home/cc/EnvGym/data/sveltejs_svelte

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build || true

ENV NODE_ENV=development
ENV PORT=5000

EXPOSE 5000

CMD ["/bin/bash"]