FROM ubuntu:22.04

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ANDROID_HOME=/usr/local/android-sdk
ENV PATH="${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV GRADLE_USER_HOME=/root/.gradle

RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    wget \
    unzip \
    git \
    curl \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-11-openjdk-amd64/bin/java" 1 \
    && update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-11-openjdk-amd64/bin/javac" 1 \
    && update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
    && update-alternatives --set javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget -q --tries=3 --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/android-sdk.zip \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/android-sdk.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/android-sdk.zip \
    && yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --install "platform-tools" "platforms;android-33" "platforms;android-26" \
    && ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --update

RUN mkdir -p ${GRADLE_USER_HOME}/wrapper/dists \
    && chmod -R 777 ${GRADLE_USER_HOME}

RUN mkdir -p /dev/kvm && chmod 777 /dev/kvm

WORKDIR /workspace
COPY . /workspace

RUN chmod +x gradlew \
    && ./gradlew --version

RUN echo "sdk.dir=${ANDROID_HOME}" > local.properties \
    && chmod -R 777 /workspace

CMD ["/bin/bash"]