# Use Ubuntu 20.04 LTS as the base image, a common choice for C++ development
FROM ubuntu:20.04

# Set environment variables to enable non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary system dependencies and build tools in a single layer
# This includes compilers (GCC, Clang), build systems (CMake, Ninja, Bazel),
# formatters, fuzzers, documentation tools, and Android development tools.
RUN apt-get update && apt-get install -y \
    # Core build essentials
    build-essential \
    git \
    cmake \
    ninja-build \
    ccache \
    # Multiple compiler toolchains (GCC is part of build-essential)
    clang-11 \
    clang-format-11 \
    # Clang's standard library for testing
    libc++-11-dev \
    libc++abi-11-dev \
    # LLVM linker
    lld-11 \
    # Fuzzing tools
    afl++ \
    # Documentation generation
    python3.8 \
    python3-pip \
    doxygen \
    # Android development
    openjdk-11-jdk \
    gradle \
    # Utilities for installing other tools
    curl \
    wget \
    unzip \
    gnupg \
    sudo \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Configure default compilers to use version 11 for consistency
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-11 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-11 100

# Install Bazel using its official APT repository
RUN wget -qO- https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/bazel.gpg && \
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    apt-get update && apt-get install -y bazel && \
    rm -rf /var/lib/apt/lists/*

# Install Android Command-Line Tools, SDK, and NDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools
# Using a fixed version of command-line tools for reproducibility
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip" -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip && \
    # Accept licenses and install required SDK/NDK components
    yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "platform-tools" "platforms;android-31" "build-tools;31.0.0" "ndk;21.3.6528147" > /dev/null && \
    # Create a symlink for easier access to the NDK
    ln -s ${ANDROID_SDK_ROOT}/ndk/21.3.6528147 ${ANDROID_SDK_ROOT}/ndk-bundle

# Install Python packages for documentation generation
RUN pip3 install --no-cache-dir \
    mkdocs \
    mkdocs-material \
    "mkdocstrings[cpp]" \
    mike

# Install 'act' to allow local testing of GitHub Actions workflows
RUN curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b /usr/local/bin

# Create a non-root user 'cc' to match the specified environment path and for better security
RUN useradd -ms /bin/bash -u 1000 -d /home/cc cc && \
    echo "cc ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up the project directory structure
ENV REPO_PATH=/home/cc/EnvGym/data/fmtlib_fmt
RUN mkdir -p ${REPO_PATH} && chown -R cc:cc /home/cc

# Switch to the non-root user
USER cc
WORKDIR ${REPO_PATH}

# Clone the {fmt} library source code into the working directory
RUN git clone --depth 1 https://github.com/fmtlib/fmt.git .

# Create a build directory and perform an initial configuration and build.
# This ensures the environment is ready for immediate use, with dependencies
# like Google Test already fetched by CMake.
RUN mkdir build && cd build && \
    cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DFMT_TEST=ON && \
    cmake --build . --parallel $(nproc)

# Set the final working directory and the default command to start a shell
WORKDIR ${REPO_PATH}
CMD ["/bin/bash"]