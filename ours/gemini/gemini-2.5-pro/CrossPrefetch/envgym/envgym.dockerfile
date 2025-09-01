# Use a standard Ubuntu 20.04 base image, compatible with linux/amd64 and without GPU dependencies.
FROM ubuntu:20.04

# Set the environment to non-interactive to prevent prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary build tools and Python dependencies.
# Clean up apt cache to reduce image size.
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    cmake \
    build-essential \
    python3-pip \
    python3-dev \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container.
WORKDIR /app

# Copy the build context (source code, requirements.txt, etc.) into the container.
COPY . /app

# Install Python packages from requirements.txt.
RUN pip3 install --no-cache-dir -r requirements.txt

# Create and switch to a build directory for an out-of-source build.
WORKDIR /app/build

# Configure the project using CMake.
RUN cmake ..

# Compile the main project, leveraging multiple cores for a faster build.
# nproc will automatically use the number of available processing units.
RUN make -j$(nproc)

# Switch to the prefetcher subdirectory.
WORKDIR /app/prefetcher

# Compile the prefetcher component, also leveraging multiple cores.
RUN make -j$(nproc)

# Return to the repository root for the final command.
WORKDIR /app

# Set the default command to start a bash shell.
CMD ["/bin/bash"]