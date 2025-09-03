FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM=linux/amd64

# System dependencies and preparation
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    git \
    sudo \
    software-properties-common \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 11
RUN apt-get update && apt-get install -y openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -P /tmp \
    && tar xf /tmp/apache-maven-3.8.6-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.8.6 /opt/maven \
    && rm /tmp/apache-maven-3.8.6-bin.tar.gz

# Miniconda installation
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/miniconda \
    && rm /tmp/miniconda.sh

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV MAVEN_HOME=/opt/maven
ENV CONDA_HOME=/opt/miniconda
ENV PATH="${MAVEN_HOME}/bin:${CONDA_HOME}/bin:${PATH}"
SHELL ["/bin/bash", "-c"]

# Create working directory
WORKDIR /exli

# Copy repository contents
COPY . .

# Initialize conda and create environment
RUN source /opt/miniconda/etc/profile.d/conda.sh \
    && conda init bash \
    && source ~/.bashrc \
    && conda create -n research python=3.8 -y

# Activate environment and install dependencies
RUN source /opt/miniconda/etc/profile.d/conda.sh \
    && conda activate research \
    && pip install --upgrade pip setuptools wheel \
    && pip install -v -e python \
    && pip install -v -e .

# Set entrypoint to bash with repository loaded
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]