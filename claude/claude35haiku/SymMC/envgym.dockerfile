FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ant \
    cmake \
    g++ \
    make \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /symmc

# Copy the entire repository
COPY . .

# Build Enhanced_Kodkod module
WORKDIR /symmc/Enhanced_Kodkod
RUN chmod +x build.sh && ./build.sh

# Build Enumerator_Estimator module
WORKDIR /symmc/Enumerator_Estimator
RUN chmod +x build.sh && ./build.sh

# Set the working directory to the root of the repository
WORKDIR /symmc

# Default command to start a bash shell
CMD ["/bin/bash"]