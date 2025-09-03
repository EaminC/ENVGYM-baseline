FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Core system and development dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-11 \
    g++-11 \
    cmake \
    ninja-build \
    python3-pip \
    python3-dev \
    git \
    wget \
    software-properties-common \
    ccache \
    meson

# Set GCC 11 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    conan==1.53.0 \
    setuptools

# Set working directory
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/catchorg_Catch2

# Configure build environment
ENV CMAKE_BUILD_PARALLEL_LEVEL=96
ENV CONAN_V2_MODE=1

# Clone and install Catch2
RUN git clone https://github.com/catchorg/Catch2.git . \
    && git checkout v3.9.1 \
    && mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DCATCH_BUILD_TESTING=ON \
             -DCATCH_ENABLE_WERROR=OFF \
             -G Ninja .. \
    && ninja install

# Set entrypoint
CMD ["/bin/bash"]