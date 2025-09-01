FROM ubuntu:20.04

# Set non-interactive mode for package installations
ENV DEBIAN_FRONTEND=noninteractive

# Define environment variables for Java versions, paths, and project settings
ENV JAVA_HOME_8=/usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME_11=/usr/lib/jvm/java-11-openjdk-amd64
ENV JAVA_HOME=${JAVA_HOME_11}
ENV ELECT_HOME=/home/cc/EnvGym/data/ELECT
ENV PATH="${JAVA_HOME}/bin:/home/cc/.local/bin:${PATH}"
ENV LANG=en_US.UTF-8
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

# Update package lists and install prerequisite packages for adding repositories
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg \
    ca-certificates

# Add PPA for specific Python versions and update package lists again
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Install Java Development Kits
RUN apt-get install -y --no-install-recommends openjdk-11-jdk openjdk-8-jdk

# Install Build tools
RUN apt-get install -y --no-install-recommends ant ant-optional ant-junit maven clang llvm make quilt debhelper dh-python

# Install Python runtimes and development libraries
RUN apt-get install -y --no-install-recommends \
    libisal-dev \
    python2 libpython2-dev \
    python3.6 python3.6-dev \
    python3.8 python3.8-dev \
    python3-pip python3-virtualenv

# Install System utilities
RUN apt-get install -y --no-install-recommends \
    ansible bc git jq rsync curl xz-utils postgresql-client bash-completion procps sudo

# Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install build-time Python dependencies via pip
RUN python3.8 -m pip install --no-cache-dir --upgrade pip && \
    pip3.8 install --no-cache-dir cython

# Create the 'cc' user as specified in the plan
RUN useradd --create-home --shell /bin/bash -d /home/cc cc && \
    echo "cc ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cc-user && \
    mkdir -p ${ELECT_HOME} && \
    chown -R cc:cc /home/cc

# Switch to the non-root 'cc' user
USER cc
WORKDIR /home/cc

# Clone the required cassandra-dtest repository
RUN git clone https://github.com/apache/cassandra-dtest.git /home/cc/cassandra-dtest

# Set the primary working directory
WORKDIR ${ELECT_HOME}

# Copy the project source code into the working directory
# Assumes the Dockerfile is run from the root of the ELECT repository
COPY --chown=cc:cc . .

# Install Python library dependencies for the project and dtests
RUN pip3.8 install --no-cache-dir --user -r src/elect/pylib/requirements.txt && \
    pip3.8 install --no-cache-dir --user -r /home/cc/cassandra-dtest/requirements.txt

# Build the native erasure coding library
RUN cd src/elect/src/native/src/org/apache/cassandra/io/erasurecode && \
    ./genlib.sh

# Copy the built native library to the expected location
RUN mkdir -p src/elect/lib/sigar-bin && \
    cp src/elect/src/native/src/org/apache/cassandra/io/erasurecode/libec.so src/elect/lib/sigar-bin/

# Build ELECT Prototype using Ant with Java 11
RUN cd src/elect && \
    ant realclean && \
    ant -Duse.jdk11=true

# Build Python utility libraries
RUN cd src/elect/pylib && \
    python3.8 setup.py build

# Build Object Storage Backend with high parallelization
RUN cd src/coldTier && \
    make clean && \
    make -j96

# Build YCSB Tool with high parallelization
RUN cd scripts/ycsb && \
    mvn -T 96 clean package

# Set the final working directory to the project root
WORKDIR ${ELECT_HOME}

# Start a bash shell, providing an interactive environment ready for use
CMD ["/bin/bash"]