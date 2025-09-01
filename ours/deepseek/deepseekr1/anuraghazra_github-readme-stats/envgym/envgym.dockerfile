FROM node:22-bullseye

RUN apt-get update && \
    apt-get install -y build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    git

RUN npm install -g vercel@latest

RUN mkdir -p /home/cc/EnvGym/data/anuraghazra_github-readme-stats
WORKDIR /home/cc/EnvGym/data/anuraghazra_github-readme-stats

RUN git clone https://github.com/anuraghazra/github-readme-stats.git .
RUN echo "PAT_1=" > .env
RUN echo '{"builds": [{"src": "*.js", "use": "@vercel/node"}], "headers": [{"source": "/(.*)", "headers": [{"key": "Cache-Control", "value": "max-age=21600"}]}]}' > vercel.json
RUN mkdir -p test/unit && touch test/unit/api.test.js

RUN npm install
RUN npm run generate-langs-json
RUN npm run lint
RUN npm run format
RUN npm run theme-readme-gen

EXPOSE 3000
CMD ["/bin/bash"]