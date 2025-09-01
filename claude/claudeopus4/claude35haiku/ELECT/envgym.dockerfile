FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-11-jre \
    ant \
    ant-optional \
    maven \
    clang \
    llvm \
    libisal-dev \
    python3 \
    python3-pip \
    ansible \
    bc \
    git \
    ssh \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install \
    cassandra-driver \
    numpy \
    scipy

# Set Java Home for isa-l library
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy repository contents
COPY . /elect
WORKDIR /elect

# Prepare build steps (comment out actual build to allow manual execution)
RUN mkdir -p ~/.m2 \
    && mkdir -p /elect/src/elect/build /elect/src/elect/lib \
    && mkdir -p /elect/src/coldTier

# Expose any necessary ports
EXPOSE 8080

# Set default shell to bash
ENTRYPOINT ["/bin/bash"]