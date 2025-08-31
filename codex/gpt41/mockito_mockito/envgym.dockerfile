# Envgym Dockerfile for Mockito (Java/Gradle)
FROM ubuntu:20.04

# System setup
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    git \
    curl \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /repo

# Copy contents to container
COPY . /repo

# Ensure gradlew is executable
RUN chmod +x gradlew

# Pre-download Gradle and dependencies (optional, speeds up dev)
RUN ./gradlew tasks || true

# Set JAVA_HOME for convenience
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Default to interactive bash shell in repo root
CMD ["/bin/bash"]
