# Use Ubuntu 20.04 as the base image for broad compiler compatibility
FROM ubuntu:20.04

# Set non-interactive mode for package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisite tools for adding repositories
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    gnupg \
    ca-certificates

# Add PPA for newer GCC versions and the LLVM repository
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/llvm-archive-keyring.gpg && \
    echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal main" >> /etc/apt/sources.list.d/llvm.list

# Update package list again and install all build tools and compilers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3.8 \
    python3-pip \
    python3.8-venv \
    cmake \
    meson \
    ninja-build \
    valgrind \
    lcov \
    doxygen \
    graphviz \
    curl \
    g++-9 g++-10 g++-11 g++-12 g++-13 \
    clang-8 clang-9 clang-10 clang-11 clang-12 clang-13 clang-14 clang-15 \
    clang-tidy-15 clang-format-15 && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Bazelisk (the recommended wrapper for Bazel)
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 -o /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk

# Install Python-based development and CI tools
RUN pip3 install --no-cache-dir \
    "guardonce>=0.5" \
    "codecov>=2.1"

# Create Python virtual environments for Conan 1.x and 2.x in /opt
RUN python3.8 -m venv /opt/conan1_env && \
    /opt/conan1_env/bin/pip install --no-cache-dir "conan<2" && \
    python3.8 -m venv /opt/conan2_env && \
    /opt/conan2_env/bin/pip install --no-cache-dir "conan>=2.1,<3"

# Create symbolic links for easy access to different Conan versions
RUN ln -s /opt/conan1_env/bin/conan /usr/local/bin/conan1 && \
    ln -s /opt/conan2_env/bin/conan /usr/local/bin/conan2

# Create a non-root user and the project directory structure
RUN useradd -m -s /bin/bash cc && \
    mkdir -p /home/cc/EnvGym/data && \
    mkdir -p /home/cc/EnvGym/verify_catch2 && \
    mkdir -p /home/cc/EnvGym/verify_catch2_conan

# Copy the repository source code (assuming build context is repo root)
COPY . /home/cc/EnvGym/data/catchorg_Catch2

# Set ownership for the non-root user
RUN chown -R cc:cc /home/cc

# Switch to the non-root user
USER cc
WORKDIR /home/cc

# Create the common C++ test source file
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2/test.cpp
#include <catch2/catch_test_macros.hpp>

unsigned int Factorial( unsigned int number ) {
    return number <= 1 ? number : Factorial(number-1)*number;
}

TEST_CASE( "Factorials are computed", "[factorial]" ) {
    REQUIRE( Factorial(1) == 1 );
    REQUIRE( Factorial(2) == 2 );
    REQUIRE( Factorial(3) == 6 );
    REQUIRE( Factorial(10) == 3628800 );
}
EOF

# Copy the test file to the Conan verification directory
RUN cp /home/cc/EnvGym/verify_catch2/test.cpp /home/cc/EnvGym/verify_catch2_conan/test.cpp

# Create the CMakeLists.txt for the standard verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2/CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(Catch2Verification CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find the installed Catch2 package
# Pass -DCMAKE_PREFIX_PATH=/path/to/install/dir during configuration
find_package(Catch2 3 REQUIRED)

add_executable(run_verification_test test.cpp)

# Link against the Catch2WithMain library which provides the main() function
target_link_libraries(run_verification_test PRIVATE Catch2::Catch2WithMain)
EOF

# Create the meson.build file for the Meson verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2/meson.build
project('catch2-verification', 'cpp', version: '1.0')

# Find the installed Catch2 dependency using pkg-config
catch2_dep = dependency('catch2-with-main', version: '>=3.0.0')

executable(
  'run_verification_test_meson',
  'test.cpp',
  dependencies: catch2_dep,
  # C++ standard can be controlled via the CXXFLAGS environment variable
)
EOF

# Create the MODULE.bazel file for the Bazel verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2/MODULE.bazel
module(name = "catch2_verification")

bazel_dep(name = "rules_cc", version = "0.1.1")

# Override the catch2 dependency to use the local clone instead of
# fetching it from a registry.
local_path_override(
    module_name = "catch2",
    path = "/home/cc/EnvGym/data/catchorg_Catch2",
)
EOF

# Create the BUILD.bazel file for the Bazel verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2/BUILD.bazel
load("@rules_cc//cc:defs.bzl", "cc_test")

cc_test(
    name = "run_verification_test_bazel",
    srcs = ["test.cpp"],
    # Depend on the catch2_main target which includes the main() implementation
    deps = ["@catch2//:catch2_main"],
)
EOF

# Create the conanfile.txt for the Conan verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2_conan/conanfile.txt
[requires]
# Replace X.Y.Z with the version of Catch2 you are building
catch2/X.Y.Z@user/testing

[generators]
CMakeDeps
CMakeToolchain
EOF

# Create the CMakeLists.txt for the Conan verification project
RUN cat <<'EOF' > /home/cc/EnvGym/verify_catch2_conan/CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project(Catch2ConanVerification CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Conan will generate the necessary FindCatch2.cmake files
find_package(catch2 REQUIRED)

add_executable(run_verification_test_conan test.cpp)

# Link against the target provided by the Conan package
target_link_libraries(run_verification_test_conan PRIVATE catch2::catch2main)
EOF

# Set the final working directory to the root of the copied repository
WORKDIR /home/cc/EnvGym/data/catchorg_Catch2

# Start a bash session as the entrypoint
CMD ["/bin/bash"]