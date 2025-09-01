# Dockerfile for Alibaba Fastjson2 Development Environment
FROM openjdk:8-jdk-slim

# Install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    maven \
    bash

# Set working directory
WORKDIR /app

# Copy the entire repository
COPY . /app

# Install project dependencies
RUN mvn clean install -DskipTests

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]