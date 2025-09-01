FROM ubuntu:22.04

ARG TARGETARCH=amd64
ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -m itdocker && \
    mkdir -p /home/itdocker/EnvGym && \
    chown -R itdocker:itdocker /home/itdocker

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    zip \
    unzip \
    vim \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6 \
    libx11-xcb1 \
    libdrm2 \
    libgbm1 \
    libasound2 \
    libxshmfence1 \
    bzip2 && \
    rm -rf /var/lib/apt/lists/*

USER itdocker
WORKDIR /home/itdocker
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /home/itdocker/miniconda && \
    rm miniconda.sh
ENV PATH="/home/itdocker/miniconda/bin:$PATH"

RUN /home/itdocker/miniconda/bin/conda init bash && \
    /home/itdocker/miniconda/bin/conda config --set auto_activate_base false && \
    /home/itdocker/miniconda/bin/conda create -y -n envgym python=3.9 && \
    /home/itdocker/miniconda/bin/conda install -n envgym -y \
    pip \
    xmltodict \
    tqdm \
    flake8 \
    black \
    ipykernel \
    seaborn \
    unidiff \
    gensim \
    pandas \
    matplotlib \
    scipy \
    beautifulsoup4 && \
    /home/itdocker/miniconda/bin/conda clean -ya

RUN bash -c "curl -s 'https://get.sdkman.io' | bash && \
    source $HOME/.sdkman/bin/sdkman-init.sh && \
    sdk install java 8.0.302-open && \
    sdk install maven 3.8.6 && \
    sdk default java 8.0.302-open"

ENV MAVEN_HOME="/home/itdocker/.sdkman/candidates/maven/current"
ENV PATH="${MAVEN_HOME}/bin:$PATH"

WORKDIR /home/itdocker/EnvGym
RUN mkdir -p data/exli/results/{target-stmt,mutants,r2,r0-tests,r1-tests,r0-tests-all,r1-tests-all,plots,tables} && \
    mkdir -p data/exli/log && \
    touch data/exli/log/raninline.log

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz && \
    tar -xvzf geckodriver-v0.31.0-linux64.tar.gz && \
    chmod +x geckodriver && \
    mv geckodriver /usr/local/bin/ && \
    rm geckodriver-v0.31.0-linux64.tar.gz

WORKDIR /exli
CMD ["/bin/bash"]