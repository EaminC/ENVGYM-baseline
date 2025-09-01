# Use Ubuntu 24.04 as the base image, aligning with the CI environment plan.
FROM ubuntu:24.04

# Set environment variables to enable non-interactive installation.
ENV DEBIAN_FRONTEND=noninteractive

# Install all build prerequisites for building Ponyc from source on Debian/Ubuntu.
# This follows "Method B: Build from Source (for Contributors)" from the plan.
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    git \
    libclang-rt-dev \
    libstdc++-13-dev \
    lldb \
    lsb-release \
    make \
    openjdk-11-jdk-headless \
    python3-pip \
    systemtap-sdt-dev \
    wget \
    xz-utils \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory as specified in the plan.
WORKDIR /home/cc/EnvGym/data/ponylang_ponyc

# Acquire the source code by cloning the repository and its submodules.
# The clone is performed into the current working directory.
RUN git clone --recurse-submodules https://github.com/ponylang/ponyc.git .

# Install ANTLR v3, a required tool for generating the parser.
# This follows the method used in the project's CI scripts.
RUN mkdir -p third-party/antlr && \
    wget -q -O third-party/antlr/antlr-3.5.2-complete.jar https://www.antlr3.org/download/antlr-3.5.2-complete.jar

# Create a VERSION file if it doesn't exist, as required by the build system.
RUN if [ ! -f VERSION ]; then echo "0.59.0" > VERSION; fi

# Build core dependencies (LLVM, etc.), leveraging all available CPU cores.
# This is the most time-consuming step of the build process.
RUN make libs build_flags="-j$(nproc)"

# Configure and build the 'debug' version of the compiler.
RUN make configure arch=x86-64 config=debug && \
    make build config=debug build_flags="-j$(nproc)"

# Configure and build the 'release' version of the compiler.
RUN make configure arch=x86-64 config=release && \
    make build config=release build_flags="-j$(nproc)"

# Add the compiled 'release' binaries to the PATH to make them "ready to use".
ENV PATH="/home/cc/EnvGym/data/ponylang_ponyc/build/release:${PATH}"

# Set the default command to start a bash shell, placing the user in the repository root.
CMD ["/bin/bash"]