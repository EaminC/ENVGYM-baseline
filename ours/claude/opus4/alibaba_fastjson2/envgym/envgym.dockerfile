FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    unzip \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    openjdk-11-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y \
    gradle \
    ant \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/alibaba_fastjson2

RUN git clone https://github.com/alibaba/fastjson2.git . || true

RUN mvn dependency:go-offline || true

CMD ["/bin/bash"]