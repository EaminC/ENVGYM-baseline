# Use a recent Ubuntu LTS release as the base image.
# It provides a stable environment with access to modern compilers and tools.
FROM ubuntu:22.04

# Set the DEBIAN_FRONTEND to noninteractive to prevent prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary system dependencies for building, testing, and developing the project.
# This includes:
# - Core build tools: build-essential, cmake, git, ninja-build, g++, make
# - Compilers and formatters: clang, clang-format
# - Scripting languages: python3, nodejs (via nodesource)
# - Debugging/Analysis tools: valgrind
# - Documentation tools: doxygen, graphviz
# - Integration tools: pkg-config
# - Utilities: curl, wget, zip, unzip, sudo for privilege escalation
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    g++ \
    clang \
    clang-format \
    python3 \
    pkg-config \
    curl \
    make \
    doxygen \
    graphviz \
    valgrind \
    zip \
    unzip \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install a recent version of Node.js and npm using the official NodeSource repository.
# This is required for running helper scripts, such as the large JSON generator.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

# Install the Rust toolchain (rustc, cargo) using rustup.
# This is required for building the serde benchmark for static reflection comparisons.
# The toolchain is installed system-wide for easy access.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Create a non-root user 'dev' for development to follow best practices.
# Grant sudo access without a password for convenience within the container.
RUN useradd --create-home --shell /bin/bash dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the non-root user.
USER dev

# Set the working directory to the user's home directory.
WORKDIR /home/dev

# Clone the simdjson repository from GitHub.
RUN git clone --depth 1 https://github.com/simdjson/simdjson.git

# Set the working directory to the cloned repository.
WORKDIR /home/dev/simdjson

# Install JavaScript dependencies for helper scripts.
RUN cd scripts/javascript && npm install

# Create a build directory and configure the project with CMake.
# - Use the Ninja generator for fast, parallel builds.
# - Set build type to Debug for better debugging support.
# - Enable developer mode to build tests, examples, and benchmarks.
# - Export compile commands for IDE/editor integration (e.g., clangd).
# This step will also download and cache external dependencies like Google Benchmark.
RUN cmake -B build -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DSIMDJSON_DEVELOPER_MODE=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .

# Build the project, including the library, tests, and examples.
# This uses all available processor cores for maximum speed.
RUN cmake --build build -j$(nproc)

# Set the default command to start an interactive bash shell.
# The user will be placed in the project's root directory, ready to run tests,
# edit code, and rebuild.
CMD ["/bin/bash"]