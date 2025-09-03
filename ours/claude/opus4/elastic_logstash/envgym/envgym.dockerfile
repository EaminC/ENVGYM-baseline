FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update

# Install core utilities
RUN apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    nano \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Java and build tools
RUN apt-get update && apt-get install -y \
    default-jdk \
    maven \
    gradle \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install other languages
RUN apt-get update && apt-get install -y \
    golang-go \
    ruby \
    ruby-dev \
    php \
    php-cli \
    composer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install database clients
RUN apt-get update && apt-get install -y \
    postgresql-client \
    default-mysql-client \
    redis-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel

WORKDIR /workspace

COPY . /workspace/

RUN if [ -f requirements.txt ]; then pip3 install -r requirements.txt; fi
RUN if [ -f package.json ]; then npm install; fi
RUN if [ -f Gemfile ]; then bundle install; fi
RUN if [ -f composer.json ]; then composer install; fi
RUN if [ -f go.mod ]; then go mod download; fi
RUN if [ -f pom.xml ]; then mvn dependency:resolve; fi
RUN if [ -f build.gradle ] && [ -f gradlew ]; then chmod +x gradlew && ./gradlew dependencies || true; elif [ -f build.gradle ]; then gradle dependencies || true; fi

ENV PATH="/workspace/bin:${PATH}"

CMD ["/bin/bash"]