FROM ubuntu:18.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    python2.7 \
    python-pip \
    bc \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Java 8
RUN add-apt-repository ppa:webupd8team/java \
    && apt-get update \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections \
    && apt-get install -y oracle-java8-installer

# Set up working directory
WORKDIR /probfuzz

# Copy the entire repository
COPY . .

# Install Python 2 dependencies
RUN pip2 --no-cache-dir install \
    antlr4-python2-runtime \
    six \
    astunparse \
    ast \
    pystan \
    edward \
    pyro-ppl==0.2.1 \
    tensorflow==1.5.0 \
    pandas

# Install specific torch version for Python 2
RUN pip2 install http://download.pytorch.org/whl/cpu/torch-0.4.0-cp27-cp27mu-linux_x86_64.whl

# Set up ANTLR
RUN cd language/antlr/ \
    && wget http://www.antlr.org/download/antlr-4.7.1-complete.jar \
    && chmod +x run.sh \
    && ./run.sh

# Run initial check
RUN ./check.py

# Default command to start bash
CMD ["/bin/bash"]