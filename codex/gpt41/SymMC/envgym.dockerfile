FROM ubuntu:20.04

# Need noninteractive to avoid tzdata/cert prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    zlib1g-dev \
    libgmp-dev \
    openjdk-8-jdk \
    ant \
    python3 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /workspace

# Copy the entire repo contents into the docker image
COPY . /workspace

# Build Enhanced_Kodkod (Java/Ant)
RUN cd Enhanced_Kodkod && ant compile

# Build Enumerator_Estimator (MiniSat C++/CMake)
RUN cd Enumerator_Estimator && ./build.sh

# Put user into bash at repo root
WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
