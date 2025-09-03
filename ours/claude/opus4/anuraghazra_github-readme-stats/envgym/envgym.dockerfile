FROM --platform=linux/amd64 node:22-alpine

RUN apk add --no-cache \
    git \
    bash \
    python3 \
    make \
    g++ \
    curl

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run prepare || true

RUN npm i -g vercel

RUN echo 'PAT_1=your_github_token_here' > .env && \
    echo 'CACHE_SECONDS=1800' >> .env

RUN echo 'PAT_1=your_github_token_here' > .env.example && \
    echo 'CACHE_SECONDS=1800' >> .env.example

RUN if [ ! -f jest.config.js ]; then \
    echo "module.exports = { testEnvironment: 'jsdom' };" > jest.config.js; \
    fi

RUN if [ ! -f jest.e2e.config.js ]; then \
    echo "module.exports = { ...require('./jest.config.js'), testMatch: ['**/*.e2e.test.js'] };" > jest.e2e.config.js; \
    fi

RUN if [ ! -f jest.bench.config.js ]; then \
    echo "module.exports = { ...require('./jest.config.js'), testMatch: ['**/*.bench.js'] };" > jest.bench.config.js; \
    fi

RUN if [ ! -f express.js ]; then \
    echo "const express = require('express');" > express.js && \
    echo "const app = express();" >> express.js && \
    echo "const port = process.env.PORT || 3000;" >> express.js && \
    echo "" >> express.js && \
    echo "app.use('/api', require('./api/index'));" >> express.js && \
    echo "app.use('/api/pin', require('./api/pin'));" >> express.js && \
    echo "app.use('/api/gist', require('./api/gist'));" >> express.js && \
    echo "app.use('/api/top-langs', require('./api/top-langs'));" >> express.js && \
    echo "app.use('/api/wakatime', require('./api/wakatime'));" >> express.js && \
    echo "" >> express.js && \
    echo "app.listen(port, () => {" >> express.js && \
    echo "  console.log(\`Server running on port \${port}\`);" >> express.js && \
    echo "});" >> express.js; \
    fi

RUN npm install express

RUN if [ ! -f .prettierrc ]; then \
    echo '{"semi": true, "singleQuote": false}' > .prettierrc; \
    fi

RUN if [ ! -f .eslintrc.js ]; then \
    echo "module.exports = { extends: ['eslint:recommended'] };" > .eslintrc.js; \
    fi

RUN if [ ! -f .gitignore ] || ! grep -q "^\.env$" .gitignore; then \
    echo ".env" >> .gitignore; \
    fi

RUN if [ ! -f docker-compose.yml ]; then \
    echo "version: '3.8'" > docker-compose.yml && \
    echo "services:" >> docker-compose.yml && \
    echo "  app:" >> docker-compose.yml && \
    echo "    build: ." >> docker-compose.yml && \
    echo "    ports:" >> docker-compose.yml && \
    echo "      - '3000:3000'" >> docker-compose.yml && \
    echo "    env_file:" >> docker-compose.yml && \
    echo "      - .env" >> docker-compose.yml && \
    echo "    deploy:" >> docker-compose.yml && \
    echo "      resources:" >> docker-compose.yml && \
    echo "        limits:" >> docker-compose.yml && \
    echo "          memory: 512M" >> docker-compose.yml && \
    echo "          cpus: '0.5'" >> docker-compose.yml; \
    fi

EXPOSE 3000

ENV NODE_ENV=development

CMD ["/bin/bash"]