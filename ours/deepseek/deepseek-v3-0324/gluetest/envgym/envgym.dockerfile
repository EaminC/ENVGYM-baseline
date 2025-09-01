FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/cc
ENV ENVGYM=$HOME/EnvGym
ENV GLUETEST=$ENVGYM/data/gluetest

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    unzip \
    zip \
    openjdk-11-jdk \
    maven \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d $HOME -s /bin/bash cc
WORKDIR $HOME

RUN curl -s "https://get.sdkman.io" | bash \
    && chown -R cc:cc $HOME/.sdkman

USER cc

RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh \
    && sdk install java 11.0.11.hs-adpt \
    && sdk install maven 3.8.6 \
    && sdk install gradle 7.5.1"

RUN mkdir -p $GLUETEST \
    && mkdir -p $HOME/.m2/repository

WORKDIR $GLUETEST

COPY . .

RUN echo "export PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc \
    && echo "source $HOME/.sdkman/bin/sdkman-init.sh" >> $HOME/.bashrc \
    && echo "cd $GLUETEST" >> $HOME/.bashrc

WORKDIR $GLUETEST

CMD ["/bin/bash", "-l"]