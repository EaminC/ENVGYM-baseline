FROM node:18-slim

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3 \
    make \
    g++ \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://packages.mozilla.org/apt/repo-signing-key.gpg | apt-key add - \
    && echo "deb https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list \
    && apt-get update \
    && apt-get install -y firefox \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /darkreader

RUN git clone https://github.com/darkreader/darkreader.git .

RUN echo "18" > .nvmrc

RUN npm install

RUN npm run debug && npm run build

RUN echo '#!/bin/bash\n\
echo "Dark Reader Development Environment"\n\
echo "==================================="\n\
echo ""\n\
echo "Available commands:"\n\
echo "  npm run debug              - Build debug version"\n\
echo "  npm run debug:watch        - Watch mode for Chrome/Firefox development"\n\
echo "  npm run debug:watch:mv3    - Watch mode for Chrome MV3 development"\n\
echo "  npm run build              - Build release version"\n\
echo "  npm run test:unit          - Run unit tests"\n\
echo "  npm run test:browser       - Run browser tests"\n\
echo "  npm run test:inject        - Run injection tests"\n\
echo "  npm run test:coverage      - Run tests with coverage"\n\
echo "  npm run lint               - Check code style"\n\
echo "  npm run api                - Build API"\n\
echo ""\n\
echo "Build outputs:"\n\
echo "  Chrome extension: build/release/darkreader-chrome.zip"\n\
echo "  Firefox extension: build/release/darkreader-firefox.xpi"\n\
echo "  API files: darkreader.js, darkreader.mjs"\n\
echo ""\n\
exec /bin/bash' > /entrypoint.sh && chmod +x /entrypoint.sh

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

ENTRYPOINT ["/entrypoint.sh"]