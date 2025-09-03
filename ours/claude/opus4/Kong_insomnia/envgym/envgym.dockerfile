FROM node:22-bullseye

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libfontconfig-dev \
    libcurl4-openssl-dev \
    python3 \
    make \
    g++ \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libnss3-dev \
    libgtk-3-dev \
    libnotify-dev \
    libasound2-dev \
    libxtst6 \
    libatspi2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libasound2 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g npm@10

WORKDIR /workspace

RUN git clone https://github.com/Kong/insomnia.git . && \
    git remote add upstream https://github.com/Kong/insomnia.git

ENV ELECTRON_CACHE=/root/.cache/electron
ENV ELECTRON_BUILDER_CACHE=/root/.cache/electron-builder
ENV npm_config_cache=/root/.npm
ENV DISPLAY=:99

RUN rm -rf ~/.cache/electron

RUN npm install

RUN npm run postinstall || true

RUN npm run install-libcurl-electron || true

RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 &' > /usr/local/bin/start-xvfb.sh && \
    chmod +x /usr/local/bin/start-xvfb.sh

RUN echo '{"editor.formatOnSave": true, "editor.defaultFormatter": "esbenp.prettier-vscode", "eslint.enable": true, "eslint.autoFixOnSave": true}' > .vscode-settings.json

RUN echo 'root = true\n\n[*]\nindent_style = space\nindent_size = 2\nend_of_line = lf\ncharset = utf-8\ntrim_trailing_whitespace = true\ninsert_final_newline = true' > .editorconfig

RUN echo '{"singleQuote": true, "trailingComma": "all", "plugins": ["prettier-plugin-tailwindcss"]}' > .prettierrc

RUN npm run lint || true
RUN npm run type-check || true

ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/start-xvfb.sh && exec /bin/bash"]