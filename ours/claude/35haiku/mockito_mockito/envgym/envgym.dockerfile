FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Base system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    build-essential \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk

ENV JAVA_HOME_11=/usr/lib/jvm/java-11-openjdk-amd64
ENV JAVA_HOME_17=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_HOME_21=/usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_HOME=$JAVA_HOME_17

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-8.4-bin.zip && \
    unzip gradle-8.4-bin.zip -d /opt && \
    rm gradle-8.4-bin.zip

ENV GRADLE_HOME=/opt/gradle-8.4
ENV PATH=$PATH:$GRADLE_HOME/bin

# Set up working directory
RUN mkdir -p /mockito
WORKDIR /mockito

# Clone repository
RUN git clone https://github.com/mockito/mockito.git .

# Configure Gradle for performance
ENV GRADLE_OPTS="-Xmx16g -XX:MaxMetaspaceSize=1g -XX:+UseParallelGC"

# Prepare the project
RUN ./gradlew build --info --no-daemon || true

EXPOSE 8080

ENTRYPOINT ["/bin/bash"]