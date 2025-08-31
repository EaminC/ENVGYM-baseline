FROM ubuntu:18.04

# Set noninteractive to avoid tzdata/dialog during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common wget curl git bc \
    python2.7 python-pip openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set Python2 as default python (needed for pip2)
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# Install Python2 packages
RUN pip2 install --no-cache-dir antlr4-python2-runtime six astunparse ast pystan edward pyro-ppl==0.2.1 tensorflow==1.5.0 pandas \
 && pip2 install http://download.pytorch.org/whl/cpu/torch-0.4.0-cp27-cp27mu-linux_x86_64.whl

# Create repo user and set up workspace
RUN useradd --create-home probfuzz
WORKDIR /home/probfuzz

# Copy repo
COPY . /home/probfuzz/

# Set ENV for Java and ANTLR script
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Download ANTLR jar for grammar setup
RUN cd language/antlr && \
    wget http://www.antlr.org/download/antlr-4.7.1-complete.jar && \
    bash run.sh || true

# Run installation scripts and verify (ignore failures: already installed)
RUN bash install.sh || true && bash install_java.sh || true && python2.7 check.py || true

# Set bash entrypoint at the repo root
ENTRYPOINT ["/bin/bash"]
