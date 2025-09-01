FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    INSOMNIA_PATH=/workspace \
    ELECTRON_BUILDER_TARGETS="linux:deb"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    libfontconfig-dev \
    xz-utils \
    fakeroot \
    libgtk-3-0 \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xvfb \
    graphicsmagick \
    build-essential \
    python3 \
    libappindicator3-1 \
    libsecret-1-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $INSOMNIA_PATH

COPY .nvmrc .

RUN NODE_VERSION=$(tr -d '\n' < .nvmrc) && \
    NODE_VERSION=${NODE_VERSION#v} && \
    curl -O https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz && \
    tar -xJf node-v$NODE_VERSION-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    rm node-v$NODE_VERSION-linux-x64.tar.xz

ENV PATH="/usr/local/bin:$PATH"

RUN rm -rf /root/.cache/electron

COPY . .

RUN npm cache clean --force
RUN npm install
RUN npm ls --depth=0

RUN npm run app-build
RUN ls -lR packages/insomnia

RUN xvfb-run -a env ELECTRON_BUILDER_ALLOW_SUPERUSER=1 DEBUG="electron-builder*" npm run app-package -- --verbose > /tmp/electron-builder.log 2>&1 || (cat /tmp/electron-builder.log && exit 1)

RUN npm run inso-package

ENTRYPOINT ["/bin/bash"]