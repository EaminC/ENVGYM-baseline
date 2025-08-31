FROM openjdk:11

# Install required system packages
RUN apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/*

# Install required python packages
RUN pip3 install cassandra-driver numpy scipy

# Set working directory
WORKDIR /elect

# Copy entire repo into container
COPY . /elect

# Build native erasure coding library
WORKDIR /elect/src/elect/src/native/src/org/apache/cassandra/io/erasurecode
RUN chmod +x genlib.sh && ./genlib.sh

# Build ELECT project via ant
WORKDIR /elect/src/elect
RUN ant realclean && ant -Duse.jdk11=true

# Build OSSServer backend
WORKDIR /elect/src/coldTier
RUN make clean && make

# Build YCSB benchmark tool
WORKDIR /elect/scripts/ycsb
RUN mvn clean package

# Set back to repo root
WORKDIR /elect

# Default to bash shell
ENTRYPOINT ["/bin/bash"]
