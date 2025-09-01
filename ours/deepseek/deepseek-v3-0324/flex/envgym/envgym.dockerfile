FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    build-essential \
    ca-certificates \
    libblas-dev \
    liblapack-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda init bash && \
    . $CONDA_DIR/etc/profile.d/conda.sh && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict

WORKDIR /repo
COPY . /repo

RUN . $CONDA_DIR/etc/profile.d/conda.sh && \
    conda create -n flex python=3.8 -y && \
    conda activate flex && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
    astunparse \
    arviz==0.6.1 \
    rpy2==3.2.0 \
    scipy==1.5.4 \
    numpy \
    statsmodels \
    hyperopt \
    tabulate \
    pandas \
    diff-match-patch && \
    conda install -c conda-forge r-base=4.0.5 -y && \
    pip install -e .

RUN mkdir -p /home/cc/EnvGym/data/flex/projects && \
    mkdir -p /home/cc/EnvGym/data/flex/logs

CMD ["/bin/bash", "-c", "source $CONDA_DIR/etc/profile.d/conda.sh && conda activate flex && /bin/bash"]