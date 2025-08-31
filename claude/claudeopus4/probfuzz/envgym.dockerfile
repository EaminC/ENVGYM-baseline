FROM ubuntu:18.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    bc \
    wget \
    openjdk-8-jre-headless \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /probfuzz

# Copy the entire repository
COPY . .

# Install Python dependencies
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

# Install PyTorch
RUN pip2 install http://download.pytorch.org/whl/cpu/torch-0.4.0-cp27-cp27mu-linux_x86_64.whl

# Download and setup ANTLR
RUN cd language/antlr && \
    wget http://www.antlr.org/download/antlr-4.7.1-complete.jar && \
    chmod +x run.sh && \
    ./run.sh

# Make scripts executable
RUN chmod +x probfuzz.py check.py install.sh install_java.sh summary.sh

# Verify installation
RUN python2 check.py

# Set the default command to bash
CMD ["/bin/bash"]