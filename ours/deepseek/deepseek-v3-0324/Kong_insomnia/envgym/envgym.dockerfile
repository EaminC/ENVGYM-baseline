FROM node:22.17.1-bullseye

RUN apt-get update && \
    apt-get install -y \
    git \
    libfontconfig-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/Kong_insomnia
RUN git clone https://github.com/Kong/insomnia . && \
    npm install -g npm@10 && \
    npm install && \
    npm run install-libcurl-electron && \
    rm -rf ~/.cache/electron

COPY packages/insomnia/tsconfig.json ./packages/insomnia/tsconfig.json
COPY packages/insomnia-inso/tsconfig.json ./packages/insomnia-inso/tsconfig.json
COPY packages/insomnia-scripting-environment/tsconfig.json ./packages/insomnia-scripting-environment/tsconfig.json

RUN npm run postinstall && \
    npm run lint && \
    npm run type-check

ENV PATH="/home/cc/EnvGym/data/Kong_insomnia/node_modules/.bin:${PATH}"

CMD ["/bin/bash"]