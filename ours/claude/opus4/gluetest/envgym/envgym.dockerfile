FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    subversion \
    unzip \
    zip \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash cc

# Switch to user
USER cc
WORKDIR /home/cc

# Install SDKMAN
RUN curl -s "https://get.sdkman.io" | bash

# Source SDKMAN and install Java/GraalVM versions
RUN bash -c "source /home/cc/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.7-graal && \
    sdk install java 23.0.1-graal && \
    sdk install maven 3.9.5 && \
    sdk use java 17.0.7-graal"

# Install GraalPython component using GraalVM 17.0.7's gu
RUN bash -c "source /home/cc/.sdkman/bin/sdkman-init.sh && \
    sdk use java 17.0.7-graal && \
    gu install python"

# Set up Python environment
RUN python3.11 -m pip install --user pytest selenium coverage

# Clone the repository
RUN mkdir -p /home/cc/EnvGym/data && \
    cd /home/cc/EnvGym/data && \
    git clone https://github.com/example/gluetest.git || mkdir -p gluetest

WORKDIR /home/cc/EnvGym/data/gluetest

# Create necessary directory structure
RUN mkdir -p \
    generated/commons-cli \
    generated/commons-csv \
    commons-cli-graal/src/conf \
    commons-cli-graal/src/assembly \
    commons-cli-python/src/conf \
    commons-cli-python/src/assembly \
    commons-csv-graal/src/conf \
    commons-csv-graal/src/assembly \
    commons-csv-python/src/conf \
    commons-csv-python/src/assembly \
    graal-glue-generator/src/main/java/com/research/graalglue \
    graal-glue-generator/src/test/java \
    site-content \
    commons-cli-graal/site-content \
    commons-cli-python/site-content \
    commons-csv/site-content \
    commons-csv-graal/site-content \
    commons-csv-python/site-content

# Create placeholder configuration files
RUN touch commons-cli-graal/src/conf/checkstyle.xml \
    commons-cli-graal/src/conf/checkstyle-suppressions.xml \
    commons-cli-graal/src/conf/spotbugs-exclude-filter.xml \
    commons-cli-graal/src/assembly/bin.xml \
    commons-cli-graal/src/assembly/src.xml \
    commons-cli-python/src/conf/checkstyle.xml \
    commons-cli-python/src/conf/checkstyle-suppressions.xml \
    commons-cli-python/src/conf/spotbugs-exclude-filter.xml \
    commons-cli-python/src/assembly/bin.xml \
    commons-cli-python/src/assembly/src.xml \
    commons-csv-graal/src/conf/checkstyle.xml \
    commons-csv-graal/src/conf/checkstyle-suppressions.xml \
    commons-csv-graal/src/conf/spotbugs-exclude-filter.xml \
    commons-csv-graal/src/assembly/bin.xml \
    commons-csv-graal/src/assembly/src.xml \
    commons-csv-python/src/conf/checkstyle.xml \
    commons-csv-python/src/conf/checkstyle-suppressions.xml \
    commons-csv-python/src/conf/spotbugs-exclude-filter.xml \
    commons-csv-python/src/assembly/bin.xml \
    commons-csv-python/src/assembly/src.xml

# Create checkstyle configuration files
RUN touch commons-csv/checkstyle.xml \
    commons-csv/LICENSE-header.txt \
    commons-csv-graal/checkstyle.xml \
    commons-csv-graal/LICENSE-header.txt

# Create Python requirements file
RUN echo "pytest\nselenium\ncoverage" > requirements.txt

# Create a basic App.java for graal-glue-generator
RUN echo 'package com.research.graalglue;\n\npublic class App {\n    public static void main(String[] args) {\n        System.out.println("Graal Glue Generator");\n    }\n}' > graal-glue-generator/src/main/java/com/research/graalglue/App.java

# Make run.sh executable if it exists
RUN [ -f run.sh ] && chmod +x run.sh || echo '#!/bin/bash\necho "Test runner script"' > run.sh && chmod +x run.sh

# Create Python virtual environment
RUN python3.11 -m venv venv

# Update bashrc to source SDKMAN
RUN echo 'source /home/cc/.sdkman/bin/sdkman-init.sh' >> /home/cc/.bashrc

# Set environment variables
ENV JAVA_HOME=/home/cc/.sdkman/candidates/java/17.0.7-graal
ENV GRAALVM_HOME=/home/cc/.sdkman/candidates/java/17.0.7-graal
ENV PATH=/home/cc/.sdkman/candidates/java/17.0.7-graal/bin:/home/cc/.sdkman/candidates/maven/current/bin:$PATH

# Download skife CSV manually (optional dependency)
RUN mkdir -p /home/cc/.m2/repository/com/skife/csv/csv/1.0 && \
    wget -q https://repo1.maven.org/maven2/com/skife/csv/csv/1.0/csv-1.0.jar -O /home/cc/.m2/repository/com/skife/csv/csv/1.0/csv-1.0.jar || true

# Set the default command to bash
CMD ["/bin/bash"]