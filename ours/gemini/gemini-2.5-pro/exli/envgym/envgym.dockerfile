FROM continuumio/miniconda3:latest

SHELL ["/bin/bash", "-c"]

# Install system-level dependencies required for git, SDKMAN!, and project builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    zip \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'itdocker' for better security practices
RUN useradd --create-home --shell /bin/bash itdocker

# Switch to the new user
USER itdocker
WORKDIR /home/itdocker

# Install SDKMAN! for managing Java and Maven versions
RUN curl -s "https://get.sdkman.io" | bash

# Define Java and Maven versions as environment variables for clarity
ENV JAVA_VERSION 8.0.302-open
ENV MAVEN_VERSION 3.8.6

# Install the required Java and Maven versions using SDKMAN!
# Sourcing the init script makes the 'sdk' command available in the same RUN layer.
RUN source "/home/itdocker/.sdkman/bin/sdkman-init.sh" && \
    sdk install java ${JAVA_VERSION} && \
    sdk install maven ${MAVEN_VERSION}

# Copy the entire project context into the container
COPY --chown=itdocker:itdocker . /home/itdocker/exli

# Set the working directory to the project root
WORKDIR /home/itdocker/exli

# Build the Java components using Maven
# This replicates the action of the 'java/install.sh' script.
# RUN source "/home/itdocker/.sdkman/bin/sdkman-init.sh" && \
#     mvn --batch-mode -f java/raninline/pom.xml clean install && \
#     mvn --batch-mode -f java/jacoco-extension/pom.xml clean install

# Install the custom Jacoco Maven extension to the SDKMAN-managed Maven installation
# RUN source "/home/itdocker/.sdkman/bin/sdkman-init.sh" && \
#     MAVEN_HOME=$(sdk home maven ${MAVEN_VERSION}) && \
#     cp java/jacoco-extension/target/jacoco-extension-*.jar ${MAVEN_HOME}/lib/ext/

# Create the Conda environment and install Python packages
# This uses the project's provided scripts to ensure dependency consistency.
# RUN cd python && \
#     bash prepare-conda-env.sh && \
#     conda run -n exli pip install -e ".[dev,research]"

# Configure the user's shell to automatically activate the 'exli' conda environment upon login
# This makes the container "ready to use" as requested.
# RUN echo "conda activate exli" >> /home/itdocker/.bashrc

# Set the default command to launch an interactive bash shell in the project root
CMD ["/bin/bash"]