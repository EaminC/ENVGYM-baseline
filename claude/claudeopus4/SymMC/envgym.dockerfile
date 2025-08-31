FROM ubuntu:20.04

# Set non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    ant \
    cmake \
    g++ \
    make \
    zlib1g-dev \
    libgmp-dev \
    libgmpxx4ldbl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for JDK 8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create working directory
WORKDIR /SymMC

# Copy the entire repository
COPY . .

# Make build scripts executable
RUN chmod +x Enhanced_Kodkod/build.sh Enhanced_Kodkod/run.sh Enumerator_Estimator/build.sh

# Build Enhanced_Kodkod module
WORKDIR /SymMC/Enhanced_Kodkod
RUN ./build.sh

# Build Enumerator_Estimator module
WORKDIR /SymMC/Enumerator_Estimator
RUN ./build.sh

# Set working directory back to repository root
WORKDIR /SymMC

# Set bash as the default entrypoint
ENTRYPOINT ["/bin/bash"]