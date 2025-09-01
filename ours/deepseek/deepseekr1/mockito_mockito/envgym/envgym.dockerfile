FROM eclipse-temurin:17-jdk
WORKDIR /workspace
RUN apt-get update && apt-get install -y git unzip wget
ENV ANDROID_HOME /usr/local/android-sdk
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -O /tmp/commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip /tmp/commandlinetools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/tools && \
    rm /tmp/commandlinetools.zip
ENV PATH ${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/platform-tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"
COPY . .
RUN echo "sdk.dir=${ANDROID_HOME}" > local.properties && \
    echo "org.gradle.workers.max=4" >> gradle.properties && \
    echo "org.gradle.parallel=true" >> gradle.properties
RUN ./gradlew clean build --refresh-dependencies
CMD ["/bin/bash"]