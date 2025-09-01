# Dockerfile for nlohmann/json development environment

# Use a recent Ubuntu LTS release as the base image
FROM ubuntu:22.04

# Set non-interactive frontend for package installation to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install all specified system prerequisites for building, testing, and development
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    g++ \
    clang \
    clang-tools \
    cmake \
    git \
    ninja-build \
    python3-pip \
    python3-venv \
    valgrind \
    lcov \
    cppcheck \
    pkg-config \
    astyle \
    wget \
    unzip \
    ca-certificates \
    tar && \
    rm -rf /var/lib/apt/lists/*

# Set up the working directory structure as specified in the plan
WORKDIR /home/cc/EnvGym/data

# Clone the repository and check out the specific version tag v3.12.0
RUN git clone https://github.com/nlohmann/json.git nlohmann_json && \
    cd nlohmann_json && \
    git checkout v3.12.0

# Set the working directory to the repository root
WORKDIR /home/cc/EnvGym/data/nlohmann_json

# --- PART A: Build, Test, and Install the Library ---
# This section follows steps 3-6 of the plan to create a system-wide installation
RUN mkdir build-install && \
    cd build-install && \
    cmake .. -DJSON_BuildTests=ON -G Ninja && \
    cmake --build . --parallel $(nproc) && \
    ctest --output-on-failure -j$(nproc) && \
    cmake --install . && \
    cd .. && \
    rm -rf build-install

# --- PART A: Verify Installation with a Sample CMake Project ---
# This section follows step 7 of the plan to confirm the installation is usable
RUN mkdir -p /root/json-verification-project/build

COPY <<EOF /root/json-verification-project/main.cpp
#include <iostream>
#include <nlohmann/json.hpp>

int main() {
    nlohmann::json j;
    j["pi"] = 3.141;
    j["happy"] = true;
    j["name"] = "Niels";
    j["nothing"] = nullptr;
    j["answer"]["everything"] = 42;
    j["list"] = { 1, 0, 2 };
    j["object"] = { {"currency", "USD"}, {"value", 42.99} };
    std::cout << j.dump(4) << std::endl;
    return 0;
}
EOF

COPY <<EOF /root/json-verification-project/CMakeLists.txt
cmake_minimum_required(VERSION 3.5)
project(json_verification CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(nlohmann_json 3.12.0 REQUIRED)
add_executable(verify_json main.cpp)
target_link_libraries(verify_json PRIVATE nlohmann_json::nlohmann_json)
EOF

RUN cd /root/json-verification-project/build && \
    cmake .. && \
    cmake --build . && \
    ./verify_json && \
    cd / && \
    rm -rf /root/json-verification-project

# --- PART B: Set Up Advanced CI & Developer Environment ---

# Install all specified Python dependencies into a virtual environment
RUN python3 -m venv venv
RUN . venv/bin/activate && \
    pip install --no-cache-dir \
    -r docs/mkdocs/requirements.txt \
    -r tools/astyle/requirements.txt \
    -r tools/generate_natvis/requirements.txt \
    -r tools/serve_header/requirements.txt \
    -r cmake/requirements/requirements-cppcheck.txt \
    -r cmake/requirements/requirements-cpplint.txt \
    -r cmake/requirements/requirements-reuse.txt

# Download and install the CodeQL CLI for static analysis
RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.19.4/codeql-bundle-linux64.tar.gz -O /tmp/codeql.tar.gz && \
    tar -xzf /tmp/codeql.tar.gz -C /opt && \
    rm /tmp/codeql.tar.gz
ENV PATH="/opt/codeql:${PATH}"

# Configure the CI build (without building) so all targets are ready for the user
RUN mkdir build-ci && \
    cd build-ci && \
    cmake .. -DJSON_CI=On -G Ninja

# --- Finalization: Configure the shell environment for the user ---

# Automatically activate the Python virtual environment upon login
RUN echo "source /home/cc/EnvGym/data/nlohmann_json/venv/bin/activate" >> /root/.bashrc

# Set final working directory and the default command to start a bash shell
WORKDIR /home/cc/EnvGym/data/nlohmann_json
CMD ["/bin/bash"]