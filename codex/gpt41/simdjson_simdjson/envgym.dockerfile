FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential cmake git python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set workdir to repo root
WORKDIR /workspace

# Copy the repo contents into the image
COPY . /workspace

# Build simdjson (release mode)
RUN mkdir -p build && cd build && \
    cmake -D SIMDJSON_DEVELOPER_MODE=ON .. && \
    cmake --build . -- -j$(nproc)

# Set bash as default entrypoint, at repo root
ENTRYPOINT ["/bin/bash"]
