FROM ubuntu:22.04

# Avoid tzdata interactive prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install dependencies needed for building
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential clang cmake git make xz-utils zlib1g-dev curl python3-pip wget systemtap-sdt-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoremove -y --purge \
  && apt-get clean -y

# Setup working directory
WORKDIR /app

# Copy all repo files
COPY . /app

# Build the project using make
RUN make

# Default command - interactive shell in repo root
CMD ["/bin/bash"]
