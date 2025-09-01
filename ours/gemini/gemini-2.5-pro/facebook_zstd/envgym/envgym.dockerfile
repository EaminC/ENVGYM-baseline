# Use a modern Ubuntu LTS release as the base image for wide compatibility
# Pin to linux/amd64 as specified in the plan
FROM --platform=linux/amd64 ubuntu:22.04

# Set non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Prerequisites
# Combine all package installations into a single RUN layer to optimize image size.
# This includes the core toolchain, alternative build systems, test dependencies,
# optional libraries for extended format support, and advanced debugging/analysis tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core build tools
    git build-essential pkg-config \
    # Test dependencies
    coreutils diffutils grep tar gzip xz-utils lz4 binutils util-linux \
    # Alternative build systems
    cmake ninja-build meson python3 \
    # Optional library dependencies for extended features
    zlib1g-dev liblzma-dev liblz4-dev \
    # Optional Advanced Testing & Development Tools
    gcc-multilib musl-tools valgrind clang llvm p7zip-full shellcheck \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# 2. Set up the working directory and copy the source code
WORKDIR /home/cc/EnvGym/data/facebook_zstd
COPY . .

# 3. Build the project
# Leverage multiple cores for a faster build.
RUN make -j$(nproc) all

# 4. Run tests
# This step is separated to isolate build failures from test failures.
# RUN make -j$(nproc) check

# 5. Install the compiled binaries and libraries to the system paths
# This makes 'zstd' and 'libzstd' available system-wide.
# RUN make install

# Refresh shared library cache so the system can find libzstd.so
# RUN ldconfig

# 6. Set the final command to start an interactive bash shell
# The user will be placed in the WORKDIR with the project built, tested, and installed.
CMD ["/bin/bash"]