FROM ubuntu:22.04

# Avoid interactive dialog during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Set workdir to /zstd which will contain the repo
WORKDIR /zstd

# Copy all repo contents into /zstd
COPY . /zstd

# Build the project using the Makefile
RUN make -j "$(nproc)"

# Start a bash shell
ENTRYPOINT ["/bin/bash"]
