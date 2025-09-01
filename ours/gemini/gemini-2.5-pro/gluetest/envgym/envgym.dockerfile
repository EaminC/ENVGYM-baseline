# Base Image: Ubuntu 20.04 (Focal Fossa)
FROM ubuntu:20.04

# Step 1 & 2: Configure Environment and Install System & Python Dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    subversion \
    curl \
    wget \
    unzip \
    software-properties-common \
    gnupg \
    && add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3.11 python3.11-distutils python3.11-venv && \
    rm -rf /var/lib/apt/lists/* && \
    python3.11 -m ensurepip && \
    python3.11 -m pip install --no-cache-dir --upgrade pip && \
    python3.11 -m pip install --no-cache-dir pytest && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Step 3: Install GraalVM
ENV JAVA_HOME=/opt/graalvm
ENV PATH=$JAVA_HOME/bin:$PATH
RUN curl -fL -o graalvm.tar.gz "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-17.0.8/graalvm-community-jdk-17.0.8_linux-x64_bin.tar.gz" && \
    mkdir -p /opt/graalvm && \
    tar -xzf graalvm.tar.gz -C /opt/graalvm --strip-components=1 && \
    rm graalvm.tar.gz

# Step 4: Install Apache Maven
RUN apt-get update && \
    apt-get install -y --no-install-recommends maven && \
    rm -rf /var/lib/apt/lists/*

# Step 5: Copy Project Files
WORKDIR /app
COPY . .

# Step 6: Install Local Benchmark Dependency for commons-csv (Optional)
# Assumes csv-1.0.jar is in the build context.
# COPY csv-1.0.jar /app/
# RUN mvn install:install-file -Dfile=./csv-1.0.jar -DgroupId=org.skife.kasparov -DartifactId=csv -Dversion=1.0 -Dpackaging=jar

# Step 7: Generate GraalVM Interoperability Glue Code
RUN python3 scripts/generate_glue.py

# Step 8: Run the Verification Script to build and test the project
RUN chmod +x run.sh && ./run.sh

# Provide files for optional steps (e.g., Step 10)
# Assumes scripts/clients/clean.csv is in the build context.
# COPY scripts/clients/clean.csv /app/scripts/clients/

# Set the final command to start a bash shell for interactive use
CMD ["/bin/bash"]