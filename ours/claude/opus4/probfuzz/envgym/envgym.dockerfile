FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    git \
    build-essential \
    python2.7 \
    python2.7-dev \
    python3.8 \
    python3-pip \
    bc \
    openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python2.7 get-pip.py && \
    rm get-pip.py

RUN pip2 install --upgrade pip setuptools wheel

RUN pip2 install \
    antlr4-python2-runtime==4.7.1 \
    six \
    astunparse \
    numpy \
    scipy \
    matplotlib \
    pandas \
    pystan

RUN pip2 install tensorflow==1.5.0

RUN pip2 install torch==0.4.0 -f https://download.pytorch.org/whl/cpu/torch_stable.html

RUN pip2 install pyro-ppl==0.2.1

RUN pip2 install edward

WORKDIR /probfuzz

COPY . .

RUN mkdir -p output

RUN wget -O language/antlr/antlr-4.7.1-complete.jar https://www.antlr.org/download/antlr-4.7.1-complete.jar

RUN chmod +x language/antlr/run.sh

RUN chmod +x install.sh install_java.sh check.py probfuzz.py

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /probfuzz

CMD ["/bin/bash"]