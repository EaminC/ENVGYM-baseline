# Use Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/London

# Install all system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    doxygen \
    locales-all \
    libtinfo5 \
    libatomic1 \
    wget \
    unzip \
    virtualbox \
    vagrant \
    pkg-config \
    libc6-dev \
    libgomp1 \
    libitm1 \
    libmpc3 \
    libc++-dev \
    libc++abi-dev \
    clang \
    curl \
    gnupg \
    apt-transport-https \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Python documentation dependencies
RUN pip3 install mkdocs-material==9.5.25 mkdocstrings==0.26.1 mike==2.1.1

# Install Gradle 6.8
RUN wget https://services.gradle.org/distributions/gradle-6.8-bin.zip -O /tmp/gradle-6.8-bin.zip \
    && unzip -d /opt/gradle /tmp/gradle-6.8-bin.zip \
    && rm /tmp/gradle-6.8-bin.zip \
    && ln -s /opt/gradle/gradle-6.8/bin/gradle /usr/bin/gradle

# Install Bazel 8.1.1
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel-archive-keyring.gpg \
    && mv bazel-archive-keyring.gpg /usr/share/keyrings \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
    && apt-get update && apt-get install -y bazel-8.1.1

# Install Android NDK r21e
RUN wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip -O /tmp/ndk.zip \
    && unzip -d /opt /tmp/ndk.zip \
    && rm /tmp/ndk.zip \
    && mv /opt/android-ndk-r21e /opt/android-ndk

# Set Android environment variables
ENV ANDROID_NDK_HOME=/opt/android-ndk \
    ANDROID_HOME=/opt/android-sdk \
    PATH="${PATH}:/opt/android-ndk:/opt/gradle/gradle-6.8/bin"

# Install Android SDK components
RUN mkdir -p /opt/android-sdk/cmdline-tools/latest \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O /tmp/sdk.zip \
    && unzip -d /opt/android-sdk/cmdline-tools/latest /tmp/sdk.zip \
    && mv /opt/android-sdk/cmdline-tools/latest/cmdline-tools/* /opt/android-sdk/cmdline-tools/latest/ \
    && rmdir /opt/android-sdk/cmdline-tools/latest/cmdline-tools \
    && rm /tmp/sdk.zip \
    && yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses \
    && /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Clone the fmt repository
RUN git clone https://github.com/fmtlib/fmt.git /fmt_project
WORKDIR /fmt_project

# Create CMake configuration files
RUN mkdir -p support/cmake \
    && echo -e '# A CMake script to find SetEnv.cmd.\nfind_program(WINSDK_SETENV NAMES SetEnv.cmd\n  PATHS "[HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Microsoft SDKs\\\\Windows;CurrentInstallFolder]/bin")\nif (WINSDK_SETENV AND PRINT_PATH)\n  execute_process(COMMAND \${CMAKE_COMMAND} -E echo "\${WINSDK_SETENV}")\nendif ()' > support/cmake/FindSetEnv.cmake \
    && echo -e '@PACKAGE_INIT@\n\nif (NOT TARGET fmt::fmt)\n  include(\${CMAKE_CURRENT_LIST_DIR}/@targets_export_name@.cmake)\nendif ()\n\ncheck_required_components(fmt)' > support/cmake/fmt-config.cmake.in \
    && echo -e 'prefix=@CMAKE_INSTALL_PREFIX@\nexec_prefix=@CMAKE_INSTALL_PREFIX@\nlibdir=@libdir_for_pc_file@\nincludedir=@includedir_for_pc_file@\n\nName: fmt\nDescription: A modern formatting library\nVersion: @FMT_VERSION@\nLibs: -L${libdir} -l@FMT_LIB_NAME@\nCflags: -I${includedir}' > support/cmake/fmt.pc.in

# Set up Bazel support files
RUN mkdir -p support/bazel \
    && echo "8.1.1" > support/bazel/.bazelversion \
    && echo "# WORKSPACE marker file needed by Bazel" > support/bazel/WORKSPACE.bazel \
    && echo -e 'module(\n   name = "fmt",\n   compatibility_level = 10,\n)\n\nbazel_dep(name = "platforms", version = "0.0.11")\nbazel_dep(name = "rules_cc", version = "0.1.1")' > support/bazel/MODULE.bazel \
    && echo -e 'load("@rules_cc//cc:defs.bzl", "cc_library")\ncc_library(\n    name = "fmt",\n    srcs = [\n        "../../src/format.cc",\n        "../../src/os.cc",\n    ],\n    hdrs = glob([\n        "../../include/fmt/*.h",\n    ]),\n    copts = select({\n        "@platforms//os:windows": ["-utf-8"],\n        "//conditions:default": [],\n    }),\n    includes = ["../../include"],\n    strip_include_prefix = "../../include",\n    visibility = ["//visibility:public"],\n)' > support/bazel/BUILD.bazel \
    && echo -e '# Bazel support\n\nTo get [Bazel](https://bazel.build/) working with {fmt} you can copy the files `BUILD.bazel`,\n`MODULE.bazel`, `WORKSPACE.bazel`, and `.bazelversion` from this folder (`support/bazel`) to the root folder of this project.\nThis way {fmt} gets bazelized and can be used with Bazel (e.g. doing a `bazel build //...` on {fmt}).\n\n## Using {fmt} as a dependency\n\n### Using Bzlmod\n\nThe [Bazel Central Registry](https://github.com/bazelbuild/bazel-central-registry/tree/main/modules/fmt) provides support for {fmt}.\n\nFor instance, to use {fmt} add to your `MODULE.bazel` file:\n\n```\nbazel_dep(name = "fmt", version = "11.1.4")\n```\n\n### Live at head\n\nFor a live-at-head approach, you can copy the contents of this repository and move the Bazel-related build files to the root folder of this project as described above and make use of `local_path_override`, e.g.:\n\n```\nlocal_path_override(\n    module_name = "fmt",\n    path = "../third_party/fmt",\n)\n```' > support/bazel/README.md

# Copy Bazel files to root
RUN cp support/bazel/.bazelversion . \
    && cp support/bazel/WORKSPACE.bazel WORKSPACE \
    && cp support/bazel/MODULE.bazel . \
    && cp support/bazel/BUILD.bazel .

# Create Android manifest
RUN echo -e '<?xml version="1.0" encoding="utf-8"?>\n<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n    package="org.fmt">\n</manifest>' > support/AndroidManifest.xml

# Initialize mkdocs configuration
RUN touch support/mkdocs.yml

# Set up Gradle wrapper
WORKDIR /fmt_project/support
RUN gradle wrapper --gradle-version 6.8
WORKDIR /fmt_project

# Set default command to bash at project root
CMD ["/bin/bash"]