FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    ca-certificates \
    software-properties-common \
    libncurses5 \
    libpulse0 \
    libglu1-mesa \
    libqt5widgets5 \
    qemu-kvm \
    openjdk-21-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV ANDROID_SDK_VERSION=11076708
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${PATH}

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O /tmp/android-tools.zip && \
    unzip /tmp/android-tools.zip -d /tmp/android-tools-unzipped && \
    mv /tmp/android-tools-unzipped/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm -rf /tmp/android-tools.zip /tmp/android-tools-unzipped

RUN yes | sdkmanager --licenses
RUN sdkmanager --install "platform-tools"
RUN sdkmanager --install "platforms;android-33"
RUN sdkmanager --install "emulator"
RUN sdkmanager --install "system-images;android-33;default;x86_64"
RUN sdkmanager --install "system-images;android-26;default;x86_64"

RUN useradd -ms /bin/bash -u 1000 cc && \
    chown -R cc:cc /opt/android-sdk

USER cc

WORKDIR /home/cc/EnvGym/data/mockito_mockito

RUN git clone https://github.com/mockito/mockito.git .

RUN ./gradlew build --stacktrace -Dorg.gradle.jvmargs="-Xmx2048m"

RUN mkdir -p mockito-core/src/test/java/org/mockito/ && \
    echo 'package org.mockito;' > mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo 'import org.junit.jupiter.api.Test;' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo 'import java.util.List;' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo 'import static org.junit.jupiter.api.Assertions.assertEquals;' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo 'import static org.mockito.Mockito.*;' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo 'class MyFirstMockitoContributionTest {' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '    @Test' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '    void testMyNewFeature() {' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '        List<String> mockedList = mock(List.class);' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '        when(mockedList.get(0)).thenReturn("first");' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '        assertEquals("first", mockedList.get(0));' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '        verify(mockedList).get(0);' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '    }' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java && \
    echo '}' >> mockito-core/src/test/java/org/mockito/MyFirstMockitoContributionTest.java

CMD ["/bin/bash"]