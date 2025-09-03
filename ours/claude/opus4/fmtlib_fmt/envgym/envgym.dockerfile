FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-11 \
    g++-11 \
    clang-14 \
    libc++-14-dev \
    libc++abi-14-dev \
    libatomic1 \
    libc6-dev \
    libgomp1 \
    libitm1 \
    libmpc3 \
    libtinfo5 \
    locales-all \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    pkg-config \
    make \
    ninja-build \
    gdb \
    valgrind \
    kcov \
    clang-format \
    clang-tidy \
    doxygen \
    openjdk-11-jdk \
    unzip \
    zip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100

RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1-linux-x86_64.sh \
    && chmod +x cmake-3.28.1-linux-x86_64.sh \
    && ./cmake-3.28.1-linux-x86_64.sh --skip-license --prefix=/usr/local \
    && rm cmake-3.28.1-linux-x86_64.sh

RUN wget -q https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 \
    && chmod +x bazelisk-linux-amd64 \
    && mv bazelisk-linux-amd64 /usr/local/bin/bazel

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    mkdocs \
    mkdocs-material \
    mkdocstrings[python-legacy] \
    pymdown-extensions \
    mike \
    cpplint

RUN mkdir -p /opt/android-sdk/cmdline-tools \
    && cd /opt/android-sdk/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip -q commandlinetools-linux-9477386_latest.zip \
    && rm commandlinetools-linux-9477386_latest.zip \
    && mv cmdline-tools latest

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-25" "build-tools;30.0.3" "ndk;21.3.6528147"

ENV ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/21.3.6528147

RUN wget -q https://services.gradle.org/distributions/gradle-7.6-bin.zip \
    && unzip -q gradle-7.6-bin.zip -d /opt \
    && rm gradle-7.6-bin.zip

ENV PATH=$PATH:/opt/gradle-7.6/bin

RUN wget -q https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0-1_amd64.deb \
    && dpkg -i vagrant_2.4.0-1_amd64.deb \
    && rm vagrant_2.4.0-1_amd64.deb

RUN apt-get update && apt-get install -y virtualbox && rm -rf /var/lib/apt/lists/*

WORKDIR /fmt

RUN git init && \
    git config --global user.email "docker@example.com" && \
    git config --global user.name "Docker User"

COPY . /fmt/

RUN mkdir -p build \
    include/fmt \
    src \
    test/gtest/gmock \
    test/gtest/gtest \
    test/compile-error-test \
    test/find-package-test \
    test/add-subdirectory-test \
    test/static-export-test \
    test/fuzzing/out_chrono \
    benchmark \
    support/cmake \
    support/bazel \
    doc \
    site \
    .vagrant \
    .github/workflows

RUN touch build/.gitkeep \
    test/fuzzing/out_chrono/.gitkeep

RUN echo "8.1.1" > .bazelversion && \
    cp .bazelversion support/bazel/.bazelversion

RUN if [ -f support/bazel/BUILD.bazel ]; then cp support/bazel/BUILD.bazel BUILD.bazel; fi && \
    if [ -f support/bazel/MODULE.bazel ]; then cp support/bazel/MODULE.bazel MODULE.bazel; fi && \
    if [ -f support/bazel/WORKSPACE.bazel ]; then cp support/bazel/WORKSPACE.bazel WORKSPACE.bazel; fi

RUN echo "filter=-legal/copyright,-build/include_subdir,-runtime/references,-build/c++11" > .cpplint.cfg

RUN chmod -R 755 /fmt

CMD ["/bin/bash"]