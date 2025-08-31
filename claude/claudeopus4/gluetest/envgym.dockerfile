# Base image with Ubuntu 22.04 for better compatibility
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-graalvm
ENV PATH=$JAVA_HOME/bin:$PATH
ENV GRAALVM_HOME=$JAVA_HOME

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    # Build tools
    build-essential \
    maven \
    # Python 3.11
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-venv \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.11

# Set Python 3.11 as default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Install SDKMAN and GraalVM 17.0.7
RUN curl -s "https://get.sdkman.io" | bash
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.7-graal && \
    sdk use java 17.0.7-graal && \
    sdk default java 17.0.7-graal"

# Install GraalPython using gu
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && \
    gu install python"

# Install Python dependencies
RUN python3.11 -m pip install --upgrade pip \
    && python3.11 -m pip install \
    pytest \
    pytest-cov \
    selenium \
    beautifulsoup4 \
    requests

# Create working directory
WORKDIR /workspace

# Copy the entire repository
COPY . /workspace/

# Set proper permissions
RUN chmod +x /workspace/run.sh

# Configure Maven to use more memory for large projects
ENV MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"

# Ensure SDKMAN is available in bash
RUN echo "source $HOME/.sdkman/bin/sdkman-init.sh" >> ~/.bashrc

# Set the default command to bash
CMD ["/bin/bash"]