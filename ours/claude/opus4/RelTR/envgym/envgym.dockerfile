FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/miniconda3/bin:${PATH}"
ENV CONDA_AUTO_UPDATE_CONDA=false

RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/yrcong/RelTR.git

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh && \
    bash Miniconda3-py37_4.10.3-Linux-x86_64.sh -b -p /root/miniconda3 && \
    rm Miniconda3-py37_4.10.3-Linux-x86_64.sh

RUN /root/miniconda3/bin/conda init bash && \
    echo "conda activate reltr" >> ~/.bashrc

RUN /root/miniconda3/bin/conda create -n reltr python=3.6 -y

SHELL ["/root/miniconda3/bin/conda", "run", "-n", "reltr", "/bin/bash", "-c"]

RUN conda install pytorch==1.6.0 torchvision==0.7.0 cpuonly -c pytorch -y && \
    conda install matplotlib -y && \
    conda install scipy=1.5.2 -y && \
    pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

WORKDIR /workspace/RelTR

RUN mkdir -p ckpt data/vg/images data/oi/images

WORKDIR /workspace/RelTR/lib/fpn
RUN chmod +x make.sh && \
    ./make.sh || true

WORKDIR /workspace/RelTR

RUN find . -type d -name __pycache__ -exec rm -rf {} + || true

RUN python -c "import torch; print(torch.__version__)"

CMD ["/root/miniconda3/bin/conda", "run", "-n", "reltr", "/bin/bash"]