FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ant \
    cmake \
    build-essential \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . /workspace

# Build Enhanced_Kodkod
WORKDIR /workspace/Enhanced_Kodkod
RUN ant

# Build Enumerator_Estimator
WORKDIR /workspace/Enumerator_Estimator
RUN bash build.sh

# Return to workspace root
WORKDIR /workspace

CMD ["/bin/bash"]
