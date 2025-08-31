FROM ubuntu:20.04

# Non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl wget gnupg build-essential \
    openjdk-11-jdk \
    git ca-certificates \
    locales && \
    rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Ruby via JRuby
ENV JRUBY_VERSION=9.4.13.0
RUN mkdir -p /opt && \
    cd /opt && \
    wget https://repo1.maven.org/maven2/org/jruby/jruby-dist/${JRUBY_VERSION}/jruby-dist-${JRUBY_VERSION}-bin.tar.gz && \
    tar xzf jruby-dist-${JRUBY_VERSION}-bin.tar.gz && \
    mv jruby-${JRUBY_VERSION} jruby && \
    rm jruby-dist-${JRUBY_VERSION}-bin.tar.gz
ENV PATH="/opt/jruby/bin:$PATH"

# Install Bundler and Rake
RUN jruby -S gem install bundler rake

# Create workdir and copy source
WORKDIR /opt/src
COPY . /opt/src

# Install development dependencies
RUN ./gradlew installDevelopmentGems --no-daemon

# Entrypoint: start in repo root with bash
WORKDIR /opt/src
ENTRYPOINT ["/bin/bash"]
