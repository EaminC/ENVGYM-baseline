FROM python:3.10.12-slim

RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /RSNN

RUN pip install --upgrade pip

COPY requirements.txt .
RUN pip install numpy scipy matplotlib seaborn h5py tables pandas
RUN pip install torch==2.0.1+cpu torchvision==0.15.2+cpu torchaudio==2.0.2+cpu \
    -f https://download.pytorch.org/whl/cpu/torch_stable.html
RUN pip install omegaconf hydra-core snntorch neurobench tonic
RUN pip install git+https://github.com/fmi-basel/stork.git@40c68fe#egg=stork

RUN python -c "import torch"
RUN python -c "import numpy, scipy, matplotlib, seaborn, h5py, tables, pandas"
RUN python -c "import omegaconf, hydra, snntorch, neurobench, tonic"
RUN python -c "import stork"

RUN mkdir -p conf/data && \
    mkdir -p outputs && \
    mkdir -p dataset

RUN if [ ! -d "dataset/challenge-data" ]; then \
    wget https://zenodo.org/records/583331/files/challenge-data.zip -O /tmp/dataset.zip && \
    unzip /tmp/dataset.zip -d /RSNN/dataset && \
    rm /tmp/dataset.zip; \
    fi

COPY . .

CMD ["/bin/bash"]