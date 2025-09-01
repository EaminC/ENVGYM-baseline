FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    git \
    cmake \
    clang-tools \
    valgrind \
    zlib1g-dev \
    meson \
    ninja-build

# Set working directory
RUN mkdir -p /home/cc/EnvGym/data/facebook_zstd
WORKDIR /home/cc/EnvGym/data/facebook_zstd

# Clone repository
RUN git clone https://github.com/facebook/zstd.git . --depth 1

# Build with Make
RUN make -j$(nproc)

# Run verification tests
RUN make check

# Create non-root user for tests
RUN useradd -r -m -u 1001 appuser
RUN chown -R appuser:appuser /home/cc/EnvGym/data/facebook_zstd
USER appuser

# Run extended tests as non-root
RUN make test

# Switch back to root for installation
USER root
RUN make install

# Set default command
USER appuser
WORKDIR /home/cc/EnvGym/data/facebook_zstd
CMD ["/bin/bash"]