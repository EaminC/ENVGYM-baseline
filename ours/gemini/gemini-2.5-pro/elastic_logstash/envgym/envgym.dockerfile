# Use a stable base image with a POSIX-compliant shell and utilities.
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install system-level dependencies required for building and running the project.
# This includes Git, build tools for Ruby, Python, and utilities.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    autoconf \
    bison \
    libyaml-dev \
    libffi-dev \
    git \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Adoptium JDK 21 as required by the build plan.
RUN mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list > /dev/null && \
    apt-get update && apt-get install -y temurin-21-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Go toolchain version 1.23.
ENV GO_VERSION=1.23.0
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Docker CLI and Docker Compose to allow interaction with the host's Docker daemon.
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Create a non-root user 'cc' and the specified directory structure for better security and ownership practices.
RUN useradd -m -s /bin/bash cc && \
    mkdir -p /home/cc/EnvGym/data/elastic_logstash && \
    chown -R cc:cc /home/cc

# Switch to the non-root user.
USER cc

# Install rbenv for Ruby version management, and then install the required JRuby version and Bundler.
ENV RBENV_ROOT=/home/cc/.rbenv
ENV PATH="${RBENV_ROOT}/bin:${PATH}"
RUN git clone --depth 1 https://github.com/rbenv/rbenv.git ${RBENV_ROOT} && \
    git clone --depth 1 https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build && \
    bash -c 'eval "$(rbenv init -)" && \
             rbenv install jruby-9.4.13.0 && \
             rbenv global jruby-9.4.13.0 && \
             gem install bundler && \
             rbenv rehash'

# Add rbenv initialization to .bashrc to ensure it's available in interactive shells.
RUN echo 'export PATH="/home/cc/.rbenv/bin:$PATH"' >> /home/cc/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> /home/cc/.bashrc

# Set the primary working directory.
WORKDIR /home/cc/EnvGym/data/elastic_logstash

# Copy the application source code into the container.
# This assumes the Docker build command is run from the root of the repository.
COPY --chown=cc:cc . .

# Create the versions.yml file with the content specified in the plan.
RUN cat <<EOF > versions.yml
# alpha and beta qualifiers are now added via VERSION_QUALIFIER environment var
logstash: 9.2.0
logstash-core: 9.2.0
logstash-core-plugin-api: 2.1.16

bundled_jdk:
  # for AdoptOpenJDK/OpenJDK jdk-14.0.1+7.1, the revision is 14.0.1 while the build is 7.1
  vendor: "adoptium"
  revision: 21.0.8
  build: 9

# jruby must reference a *released* version of jruby which can be downloaded from the official download url
# *and* for which jars artifacts are published for compile-time
jruby:
  version: 9.4.13.0
  sha256: 226d9c3a2e332f8f249838f96c20e87e0df2b9a464a11477b47be6dafb66412c
# jruby-runtime-override, if specified, will override the jruby version installed in vendor/jruby
#jruby-runtime-override:
#  url: https://oss.sonatype.org/content/repositories/snapshots/org/jruby/jruby-dist/9.3.0.0-SNAPSHOT/jruby-dist-9.3.0.0-20210723.214927-259-bin.tar.gz
#  version: 9.3.0.0-SNAPSHOT
#  sha256: IGNORE

# Note: this file is copied to the root of logstash-core because its gemspec needs it when
#       bundler evaluates the gemspec via bin/logstash
# Ensure Jackson version here is kept in sync with version used by jrjackson gem
jrjackson: 0.4.20
jackson: 2.16.2
jackson-databind: 2.16.2
EOF

# Install Python dependencies for pre-commit hooks and health report tests.
RUN pip install --user pre-commit
# RUN pip install --user -r .buildkite/scripts/health-report-tests/requirements.txt
ENV PATH="/home/cc/.local/bin:${PATH}"
RUN echo 'export PATH="/home/cc/.local/bin:$PATH"' >> /home/cc/.bashrc

# Ensure the Gradle wrapper is executable, then bootstrap the project and install all dependencies.
RUN chmod +x gradlew && \
    ./gradlew bootstrap && \
    ./gradlew installDefaultGems && \
    ./gradlew installDevelopmentGems

# Set the default command to start an interactive bash shell, placing the user
# in the repository root, ready to execute build and test commands.
CMD ["/bin/bash"]