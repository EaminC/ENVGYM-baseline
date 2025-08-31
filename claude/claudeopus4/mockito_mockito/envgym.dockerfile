# Use OpenJDK 17 as base image (supports Java 11+ requirements for Mockito 5)
FROM openjdk:17-jdk-slim

# Install necessary tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bash \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /mockito

# Copy the entire repository
COPY . /mockito

# Ensure gradlew is executable
RUN chmod +x gradlew

# Download Gradle dependencies and build the project
RUN ./gradlew build --no-daemon || true

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]