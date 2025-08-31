FROM ubuntu:20.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /elect

# Install system dependencies
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
    ansible \
    python3-pip \
    bc \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Python dependencies
RUN pip3 install cassandra-driver numpy scipy

# Copy the entire repository
COPY . /elect/

# Build the erasure coding library
WORKDIR /elect/src/elect/src/native/src/org/apache/cassandra/io/erasurecode/
RUN chmod +x genlib.sh && \
    ./genlib.sh

# Copy the library to the correct location
WORKDIR /elect/src/elect
RUN cp src/native/src/org/apache/cassandra/io/erasurecode/libec.so lib/sigar-bin || true

# Build ELECT prototype
RUN mkdir -p build lib && \
    ant realclean && \
    ant -Duse.jdk11=true

# Build the cold tier server
WORKDIR /elect/src/coldTier
RUN make clean && make

# Build YCSB
WORKDIR /elect/scripts/ycsb
RUN mvn clean package

# Create necessary directories
RUN mkdir -p /elect/src/elect/data/receivedParityHashes/ \
    /elect/src/elect/data/localParityHashes/ \
    /elect/src/elect/data/ECMetadata/ \
    /elect/src/elect/data/tmp/ \
    /elect/src/elect/logs \
    /elect/src/coldTier/data

# Set the working directory back to the root of the repository
WORKDIR /elect

# Default command is bash
CMD ["/bin/bash"]