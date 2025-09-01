FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    openjdk-17-jre \
    chromium-browser \
    jq \
    unzip \
    xdg-utils \
    xvfb \
    python3 \
    libasound2 \
    libdbus-glib-1-2 \
    && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    apt-get update && \
    apt-get install -y firefox
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs
RUN curl -fsSL https://deno.land/install.sh | sh
ENV PATH="/root/.deno/bin:$PATH"
WORKDIR /darkreader
RUN git clone https://github.com/darkreader/darkreader.git .
RUN mkdir -p tasks && echo '{"type":"module"}' > tasks/package.json && jq . tasks/package.json
RUN mkdir -p tests && echo '{"type":"module"}' > tests/package.json && jq . tests/package.json
RUN echo '"lts/*"' > .nvmrc
RUN touch .env
RUN mkdir -p test/website && cat > test/website/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Website</title>
</head>
<body>
    <h1>Test Website for DarkReader</h1>
    <p>This is a test website for browser tests</p>
</body>
</html>
EOF
RUN npm install --jobs=96 --ignore-scripts && [ -d "node_modules" ] && echo "Success"
RUN npm run test:unit
RUN mkdir -p /root/.mozilla/firefox && \
    echo -e '[Profile0]\nName=default\nIsRelative=1\nPath=default-release\n\n[General]\nStartWithLastProfile=1\nVersion=2' > /root/.mozilla/firefox/profiles.ini && \
    mkdir -p /root/.mozilla/firefox/default-release && \
    echo -e 'user_pref("extensions.webextensions.restrictedDomains", "");\nuser_pref("privacy.resistFingerprinting.block_mozAddonManager", true);' >> /root/.mozilla/firefox/default-release/prefs.js
RUN echo "Testing xvfb-run availability..." && /usr/bin/xvfb-run --help
RUN echo "Testing npm availability..." && /usr/bin/npm --version
RUN echo "Testing Firefox binary..." && /usr/bin/xvfb-run -a firefox --version
RUN echo "Testing Chromium binary..." && /usr/bin/chromium-browser --version
RUN /usr/bin/xvfb-run -a --server-args='-screen 0 1024x768x24' TEST_WORKERS=96 /usr/bin/npm run test:browser
RUN npm run test:inject
RUN NODE_OPTIONS="--max-old-space-size=8192" npm run build && ls build/release/darkreader-*.zip
RUN npm run build:plus && ls build/release/darkreader-plus-*
RUN unzip -l build/release/firefox.xpi | grep META-INF/mozilla.rsa
RUN deno --version
RUN npm run deno:bootstrap && [ -f "deno.json" ] && echo "Deno bootstrap successful"
CMD ["/bin/bash"]