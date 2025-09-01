FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV REPO_ROOT=/home/cc/EnvGym/data/elastic_logstash
ENV JAVA_HOME=/opt/jdk-21
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    tar \
    gzip \
    procps \
    findutils \
    debianutils \
    passwd \
    git \
    make \
    python3 \
    python3-pip \
    python3-venv \
    jq \
    gnupg \
    ca-certificates \
    openssl \
    logrotate \
    sysvinit-utils \
    lsb-core \
    golang-1.21 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN curl -L -O https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21%2B35/OpenJDK21U-jdk_x64_linux_hotspot_21_35.tar.gz && \
    tar xzf OpenJDK21U-jdk_x64_linux_hotspot_21_35.tar.gz -C /opt && \
    ln -s /opt/jdk-21+35 /opt/jdk-21 && \
    rm OpenJDK21U-jdk_x64_linux_hotspot_21_35.tar.gz

RUN curl -L -O https://services.gradle.org/distributions/gradle-8.7-bin.zip && \
    unzip gradle-8.7-bin.zip -d /opt && \
    ln -s /opt/gradle-8.7 /opt/gradle && \
    rm gradle-8.7-bin.zip
ENV PATH="/opt/gradle/bin:${PATH}"

RUN curl -L -O https://repo1.maven.org/maven2/org/jruby/jruby-dist/9.2.21.0/jruby-dist-9.2.21.0-bin.tar.gz && \
    tar xzf jruby-dist-9.2.21.0-bin.tar.gz -C /opt && \
    ln -s /opt/jruby-9.2.21.0 /opt/jruby && \
    rm jruby-dist-9.2.21.0-bin.tar.gz
ENV PATH="/opt/jruby/bin:${PATH}"

RUN /opt/jruby/bin/jruby -S gem install bundler -v 2.2.33 && \
    /opt/jruby/bin/jruby -S gem install rake -v 13.0.6

WORKDIR $REPO_ROOT
COPY . $REPO_ROOT

RUN mkdir -p \
    $REPO_ROOT/logs \
    $REPO_ROOT/data/queue \
    $REPO_ROOT/data/dead_letter_queue \
    $REPO_ROOT/var/log/logstash \
    $REPO_ROOT/var/run \
    $REPO_ROOT/etc/logstash/conf.d \
    $REPO_ROOT/config/ssl

RUN cd $REPO_ROOT && gradle wrapper --stacktrace --info
RUN cd $REPO_ROOT && /opt/jruby/bin/jruby -S bundle config set --local path 'vendor/bundle' && \
    /opt/jruby/bin/jruby -S bundle install --verbose --retry=3 --gemfile=$REPO_ROOT/Gemfile --jobs=4 --without development test
RUN cd $REPO_ROOT/docker/data/logstash/env2yaml && GOPATH=/tmp/go go build -o env2yaml env2yaml.go

RUN chmod +x $REPO_ROOT/docker/data/logstash/bin/docker-entrypoint

VOLUME ["$REPO_ROOT/logs", "$REPO_ROOT/data", "$REPO_ROOT/config"]
EXPOSE 5044 9600

WORKDIR $REPO_ROOT
ENTRYPOINT ["/bin/bash"]