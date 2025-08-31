FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    git \
    curl \
    wget \
    vim \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the repository
COPY . /workspace/

# Build the project
RUN mvn clean install -DskipTests -Dmaven.javadoc.skip=true

# Set the default command to bash
CMD ["/bin/bash"]