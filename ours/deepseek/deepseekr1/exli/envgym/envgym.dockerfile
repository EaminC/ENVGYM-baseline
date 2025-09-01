FROM continuumio/miniconda3:23.10.0-1

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN set -x; \
    for i in 1 2 3; do \
        apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true && break || sleep 5; \
    done && \
    apt-get install -y --no-install-recommends -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true \
        git \
        maven \
        default-jdk \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN conda init bash

RUN conda create --name exli python=3.7 -y

RUN /opt/conda/envs/exli/bin/pip install \
    seutil \
    xmltodict \
    tqdm \
    universalmutator \
    seaborn \
    unidiff \
    gensim \
    pandas \
    venn \
    beautifulsoup4 \
    flake8 \
    black \
    ipykernel

RUN echo "conda activate exli" >> ~/.bashrc

ARG MAVEN_OPTS="-T 4"
ENV MAVEN_OPTS=${MAVEN_OPTS}

COPY . /exli
RUN mkdir -p /exli/results/target-stmt \
             /exli/log \
             /exli/all-tests \
             /exli/results/r0-its-report \
             /exli/results/r1-its-report \
             /exli/results/mutants \
             /exli/generated-tests \
             /exli/exlidata

WORKDIR /exli

CMD ["/bin/bash"]