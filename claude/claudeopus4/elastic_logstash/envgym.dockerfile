FROM ubuntu:22.04

# Set non-interactive to avoid prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    libbz2-dev \
    libsqlite3-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (AdoptOpenJDK/Temurin)
RUN apt-get update && apt-get install -y software-properties-common \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/ \
    && apt-get update \
    && apt-get install -y temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install RVM (Ruby Version Manager)
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io | bash -s stable

# Enable RVM for shell
SHELL ["/bin/bash", "-l", "-c"]

# Install JRuby using RVM
RUN source /etc/profile.d/rvm.sh \
    && rvm install jruby-9.4.13.0 \
    && rvm use jruby-9.4.13.0 --default

# Install Ruby gems
RUN source /etc/profile.d/rvm.sh \
    && gem install rake bundler

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/

# Set up bundler to use the Gemfile template
RUN source /etc/profile.d/rvm.sh \
    && cp Gemfile.template Gemfile \
    && bundle config set --local path 'vendor/bundle' \
    && bundle install || true

# Set the default command to bash
CMD ["/bin/bash", "-l"]