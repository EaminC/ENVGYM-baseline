FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DOCKER_VERSION=28.3.2

WORKDIR /logstash

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    software-properties-common \
    gpg \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-pip \
    openjdk-21-jdk \
    unzip

# Install RVM
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm install 3.2.2 && rvm use 3.2.2 --default"

# Install JRuby
RUN /bin/bash -l -c "rvm install jruby-9.4.13.0"

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-8.1.1-bin.zip
RUN unzip gradle-8.1.1-bin.zip
RUN mv gradle-8.1.1 /opt/gradle
ENV PATH=$PATH:/opt/gradle/bin

# Install Docker CE
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Python setup
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get install -y python3.9 python3.9-dev python3.9-venv
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# Clone Logstash repository with verbose error tracking
RUN set -e \
    && max_attempts=5 \
    && attempt=1 \
    && while [ $attempt -le $max_attempts ]; do \
        git clone -v https://github.com/elastic/logstash.git . && break || \
        if [ $attempt -eq $max_attempts ]; then \
            echo "Detailed clone failure for attempt $attempt" && \
            echo "Checking network and repository status..." && \
            ping -c 4 github.com && \
            curl -v https://github.com/elastic/logstash.git && \
            exit 1; \
        fi; \
        sleep 10; \
        attempt=$((attempt + 1)); \
    done

# Build cache and temp directory
RUN mkdir -p /logstash_build_cache
ENV GRADLE_USER_HOME=/logstash_build_cache
ENV TMPDIR=/logstash_build_cache

# Performance and optimization settings
ENV JAVA_OPTS="-XX:+UseParallelGC -XX:MaxRAMPercentage=75.0"
ENV GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"

# Docker BuildKit
ENV DOCKER_BUILDKIT=1

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME ["/logstash"]

CMD ["/bin/bash"]