# Use a recent Ubuntu LTS as the base image, which provides many modern tools.
FROM ubuntu:24.04

# Set non-interactive frontend for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install all necessary dependencies for building, testing, cross-compiling, and documentation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Git for cloning the repository
    git \
    # C Compiler / Build Tools from the plan
    build-essential \
    pkg-config \
    # GNU Build System Tools
    make \
    autoconf \
    automake \
    libtool \
    bison \
    flex \
    # Standard Unix Utilities
    curl \
    tar \
    file \
    # Optional tools for development, debugging, and analysis
    valgrind \
    gdb \
    clang \
    clang-tools \
    lcov \
    # System library for Oniguruma (for --with-oniguruma=yes)
    libonig-dev \
    # Cross-compilation toolchain for Windows targets
    mingw-w64 \
    # Tools for building RPM packages
    rpm \
    # Documentation tools
    python3 \
    python3-pip \
    python3-venv \
    pipenv \
    # Clean up apt cache to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for the repository
WORKDIR /app

# Clone the jq repository into the working directory
RUN git clone https://github.com/jqlang/jq.git .

# Initialize the Oniguruma submodule, required for default builds
RUN git submodule update --init

# Install Python dependencies for documentation and website generation
# This makes the environment ready for Method E
RUN cd docs && pipenv sync

# Generate the initial configuration scripts so the user can run ./configure immediately
RUN autoreconf -i

# Set the default command to a bash shell to provide an interactive CLI
# The user will be placed in /app, the root of the repository.
CMD ["/bin/bash"]