FROM ubuntu:22.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Essential build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 python3.10-venv python3.10-distutils python3-pip \
    openjdk-11-jdk maven git curl wget ca-certificates \
    build-essential locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create workspace directory
WORKDIR /workspace

# Copy contents of repo into the workspace directory
COPY . /workspace

# Install Python dependencies for testing
RUN python3.10 -m pip install --upgrade pip \
    && pip install pytest

# Set JAVA_HOME for Maven
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Inform user of manual GraalVM steps (if needed)
# You can uncomment these lines if GraalVM is absolutely required:
# RUN curl -s https://get.sdkman.io | bash \
#     && bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 17.0.7-graal && gu install python"

# Entrypoint: bash at repo root
ENTRYPOINT ["/bin/bash"]
