FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    gradle \
    git \
    curl \
    vim \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /mockito

# Copy the entire repository
COPY . .

# Set executable permissions for gradlew
RUN chmod +x ./gradlew

# Set default command to bash
CMD ["/bin/bash"]