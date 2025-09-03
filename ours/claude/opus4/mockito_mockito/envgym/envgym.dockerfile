FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/33.0.2
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    zip \
    xz-utils \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    openjdk-11-jdk \
    openjdk-17-jdk \
    openjdk-21-jdk \
    maven \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    cpu-checker \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q commandlinetools-linux-11076708_latest.zip && \
    rm commandlinetools-linux-11076708_latest.zip && \
    mv cmdline-tools latest

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "system-images;android-33;google_apis;x86_64" \
    "emulator" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

RUN cd /opt && \
    wget -q https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.0/graalvm-community-jdk-21.0.0_linux-x64_bin.tar.gz && \
    tar -xzf graalvm-community-jdk-21.0.0_linux-x64_bin.tar.gz && \
    rm graalvm-community-jdk-21.0.0_linux-x64_bin.tar.gz && \
    mv graalvm-community-openjdk-21* graalvm-21

ENV GRAALVM_HOME=/opt/graalvm-21
ENV PATH=$GRAALVM_HOME/bin:$PATH

RUN cd /tmp && \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v2.0.20/kotlin-compiler-2.0.20.zip && \
    unzip -q kotlin-compiler-2.0.20.zip && \
    mv kotlinc /opt/kotlin && \
    rm kotlin-compiler-2.0.20.zip

ENV PATH=/opt/kotlin/bin:$PATH

RUN cd /opt && \
    wget -q https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-3.0.22.zip && \
    unzip -q apache-groovy-binary-3.0.22.zip && \
    rm apache-groovy-binary-3.0.22.zip && \
    mv groovy-3.0.22 groovy

ENV GROOVY_HOME=/opt/groovy
ENV PATH=$GROOVY_HOME/bin:$PATH

RUN cd /opt && \
    wget -q https://github.com/cli/cli/releases/download/v2.40.1/gh_2.40.1_linux_amd64.tar.gz && \
    tar -xzf gh_2.40.1_linux_amd64.tar.gz && \
    rm gh_2.40.1_linux_amd64.tar.gz && \
    mv gh_2.40.1_linux_amd64/bin/gh /usr/local/bin/

RUN pip3 install codecov

WORKDIR /workspace

RUN git clone https://github.com/mockito/mockito.git /workspace

RUN chmod +x gradlew

RUN mkdir -p $HOME/.android && \
    echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties

RUN update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac

RUN ./gradlew --no-daemon --version

RUN ./gradlew --no-daemon :mockito-core:dependencies --configuration compileClasspath || true

WORKDIR /workspace

CMD ["/bin/bash"]