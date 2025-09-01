# Use a recent Ubuntu LTS as the base image
FROM ubuntu:22.04

# Set ARGs for versions to easily update them
ARG JDK_8_VERSION="8u412-b08"
ARG JDK_11_VERSION="11.0.23_9"
ARG JDK_17_VERSION="17.0.11_9"
ARG GO_VERSION="1.22.3"
ARG ANDROID_CMDLINE_TOOLS_VERSION="11076708"
ARG GRAALVM_VERSION="22.3.3"
ARG GRAALVM_JAVA_VERSION="17"

# Set environment variables to avoid interactive prompts and for tool paths
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV JAVA_8_HOME=/opt/jdk8
ENV JAVA_11_HOME=/opt/jdk11
ENV JAVA_17_HOME=/opt/jdk17
ENV JAVA_HOME=${JAVA_17_HOME}
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV GO_HOME=${GOROOT}
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV GRAALVM_HOME=/opt/graalvm
ENV PATH=${JAVA_HOME}/bin:${GOROOT}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}

# Use bash for RUN commands
SHELL ["/bin/bash", "-c"]

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    git \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install JDK 8
RUN mkdir -p ${JAVA_8_HOME} && \
    wget -q --no-check-certificate "https://github.com/adoptium/temurin8-binaries/releases/download/jdk${JDK_8_VERSION}/OpenJDK8U-jdk_x64_linux_hotspot_${JDK_8_VERSION//-/}.tar.gz" -O /tmp/jdk8.tar.gz && \
    tar -xzf /tmp/jdk8.tar.gz -C ${JAVA_8_HOME} --strip-components=1 && \
    rm /tmp/jdk8.tar.gz

# Install JDK 11
RUN mkdir -p ${JAVA_11_HOME} && \
    wget -q --no-check-certificate "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-${JDK_11_VERSION//_/+}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK_11_VERSION}.tar.gz" -O /tmp/jdk11.tar.gz && \
    tar -xzf /tmp/jdk11.tar.gz -C ${JAVA_11_HOME} --strip-components=1 && \
    rm /tmp/jdk11.tar.gz

# Install JDK 17
RUN mkdir -p ${JAVA_17_HOME} && \
    wget -q --no-check-certificate "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_17_VERSION//_/+}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_17_VERSION}.tar.gz" -O /tmp/jdk17.tar.gz && \
    tar -xzf /tmp/jdk17.tar.gz -C ${JAVA_17_HOME} --strip-components=1 && \
    rm /tmp/jdk17.tar.gz

# Install Go (Golang)
RUN wget -q --no-check-certificate "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Android SDK Command-Line Tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q --no-check-certificate "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" -O /tmp/android-tools.zip && \
    unzip -q /tmp/android-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/android-tools.zip

# Install GraalVM
RUN mkdir -p ${GRAALVM_HOME} && \
    wget -q -L --no-check-certificate "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-java${GRAALVM_JAVA_VERSION}-linux-amd64-${GRAALVM_VERSION}.tar.gz" -O /tmp/graalvm.tar.gz && \
    tar -xzf /tmp/graalvm.tar.gz -C ${GRAALVM_HOME} --strip-components=1 && \
    rm /tmp/graalvm.tar.gz

# Use sdkmanager to install required Android SDK components, accept licenses, and clean up caches
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-31" "build-tools;31.0.0" && \
    rm -rf /root/.android/cache /root/.android/repositories.cfg

# Create and set the working directory for the project
WORKDIR /app

# Copy the entire project repository into the container
COPY . .

# Make the Maven and Gradle wrappers executable
RUN chmod +x mvnw && \
    if [ -f "android-test/gradlew" ]; then chmod +x android-test/gradlew; fi

# Set the default command to start a bash shell
CMD ["/bin/bash"]