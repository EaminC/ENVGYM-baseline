FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    software-properties-common \
    unzip \
    openjdk-17-jdk \
    maven \
    python3 \
    python3-pip \
    docker.io

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV PYTHONPATH=/app
ENV HOME=/root

# Download and install GraalVM CE
RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.3.1/graalvm-ce-java17-linux-amd64-22.3.1.tar.gz \
    && tar -xzf graalvm-ce-java17-linux-amd64-22.3.1.tar.gz \
    && mv graalvm-ce-java17-22.3.1 /usr/lib/jvm/graalvm \
    && rm graalvm-ce-java17-linux-amd64-22.3.1.tar.gz

# Set GraalVM environment variables
ENV GRAALVM_HOME=/usr/lib/jvm/graalvm
ENV PATH=$GRAALVM_HOME/bin:$PATH

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install Python dependencies
RUN pip3 install pytest selenium

# Build multi-module Maven project
RUN mvn clean install -f commons-cli/pom.xml -DskipTests
RUN mvn clean install -f commons-csv/pom.xml -DskipTests
RUN mvn clean install -f graal-glue-generator/pom.xml -DskipTests

# Expose any necessary ports
EXPOSE 8080

# Default command
CMD ["/bin/bash"]