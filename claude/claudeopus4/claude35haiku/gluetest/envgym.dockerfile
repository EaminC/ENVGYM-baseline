FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    maven \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    bash

# Install SDKMAN!
RUN curl -s "https://get.sdkman.io" | bash

# Install GraalVM and GraalPython
SHELL ["/bin/bash", "-c"]
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && \
    sdk install java 17.0.7-graal && \
    sdk use java 17.0.7-graal && \
    gu install python

# Install Python dependencies
RUN python3 -m pip install pytest

# Set working directory
WORKDIR /app

# Copy the entire repository
COPY . .

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]