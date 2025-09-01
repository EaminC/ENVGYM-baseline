# Use a standard Ubuntu base image for x86_64 architecture
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install system dependencies. ca-certificates to fix SSL issues with curl.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bzip2 \
    ca-certificates \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up a working directory
WORKDIR /app

# Install Micromamba (lightweight Conda) by downloading, extracting, and cleaning up
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest -o micromamba.tar.bz2 && \
    tar -xvjf micromamba.tar.bz2 bin/micromamba && \
    rm micromamba.tar.bz2

# Copy the entire application context into the image.
COPY . .

# Create the Conda environment using the yaml file.
RUN ./bin/micromamba create -f BCacheSim/install/env_cachelib-py-3.11.yaml -p /opt/conda/envs/cachelib-py-3.11 -y && \
    ./bin/micromamba clean -a -y

# Set the entrypoint to run commands within the activated Conda environment
ENTRYPOINT ["/app/bin/micromamba", "run", "-p", "/opt/conda/envs/cachelib-py-3.11"]

# Set the default command to an interactive bash shell as requested
CMD ["/bin/bash"]