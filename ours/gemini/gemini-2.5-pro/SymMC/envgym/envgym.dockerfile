# Use Ubuntu 20.04 as the base image, matching the specified environment
FROM ubuntu:20.04

# Set environment variables to allow non-interactive installation of packages
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists, add the 'universe' repository for openjdk-8-jdk,
# and install all required dependencies in a single layer.
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    ant \
    build-essential \
    cmake \
    libgmp-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the JAVA_HOME environment variable for Ant and other Java-based tools.
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Set the working directory to the project root as specified in the plan
WORKDIR /home/cc/EnvGym/data/SymMC

# Copy the entire project source code from the build context into the container
COPY . .

# Build the 'Enhanced_Kodkod' Java module.
# Change into the module's directory to isolate the build process.
WORKDIR /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod
RUN chmod +x build.sh run.sh && ant

# Build the 'Enumerator_Estimator' C++ module.
# Change into the module's directory to isolate the build process.
WORKDIR /home/cc/EnvGym/data/SymMC/Enumerator_Estimator
RUN mkdir -p cmake-build-release && \
    cd cmake-build-release && \
    cmake .. && \
    make -j$(nproc)

# Reset the working directory to the project root for the final command.
WORKDIR /home/cc/EnvGym/data/SymMC

# Set the default command to launch a bash shell.
# The user will be placed in the WORKDIR (/home/cc/EnvGym/data/SymMC)
# with the environment fully configured and compiled.
CMD ["/bin/bash"]