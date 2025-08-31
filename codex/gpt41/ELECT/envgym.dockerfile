# Dockerfile for ELECT+YCSB environment
# Ubuntu 22.04, Java 11, Python 3, Ant, Maven, native tools, repo installed
FROM ubuntu:22.04

# Set env variables for noninteractive installs
ENV DEBIAN_FRONTEND=noninteractive

# Core system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk openjdk-11-jre ant ant-optional maven clang llvm libisal-dev \
    python3 python3-pip python3-dev python3-setuptools python3-wheel \
    ansible bc git make build-essential wget curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip3 install --upgrade pip && pip3 install numpy scipy cassandra-driver coverage pytest

# Set working dir to repo root
WORKDIR /ELECT

# Copy repository contents into image
COPY . /ELECT

# Build native erasure coding lib (Isa-L based)
RUN bash -c 'cd src/elect/src/native/src/org/apache/cassandra/io/erasurecode && chmod +x genlib.sh && ./genlib.sh'
# Move built lib to expected location
RUN bash -c 'mkdir -p /ELECT/src/elect/lib/sigar-bin; cp src/elect/src/native/src/org/apache/cassandra/io/erasurecode/libec.so src/elect/lib/sigar-bin/'

# Build ELECT Java code
RUN bash -c 'cd src/elect && mkdir -p build lib && ant realclean && ant -Duse.jdk11=true'

# Build ColdTier OSSServer
RUN bash -c 'cd src/coldTier && make clean && make'

# Build YCSB tool
RUN bash -c 'cd scripts/ycsb && mvn clean package'

# Install ELECT Python libs (requires git)
RUN bash -c 'cd src/elect/pylib && pip3 install -r requirements.txt && python3 setup.py install'

# Set entrypoint to bash shell at repo root
ENTRYPOINT ["/bin/bash"]
