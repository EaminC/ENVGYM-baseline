FROM ubuntu:22.04
LABEL maintainer="nlohmann_json docker env"

# Set non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build essentials (for demos/examples in repo)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential cmake git wget nano vim \
    && rm -rf /var/lib/apt/lists/*

# Copy the repository content into /repo
WORKDIR /repo
COPY . /repo

# Default shell is bash at repo root
CMD ["/bin/bash"]
