FROM python:3.8-slim-bullseye

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH
SHELL ["/bin/bash", "-c"]

RUN source /opt/conda/etc/profile.d/conda.sh \
    && conda init bash \
    && conda create -n reltr python=3.8 --no-default-packages -y \
    && conda activate reltr \
    && pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu \
    && pip install \
        matplotlib \
        scipy \
        pycocotools \
        numpy \
        tqdm \
        opencv-python

RUN git clone https://github.com/yrcong/RelTR.git

WORKDIR /app/RelTR

RUN source /opt/conda/etc/profile.d/conda.sh \
    && conda activate reltr \
    && pip install -r requirements.txt \
    && python setup.py develop

SHELL ["/opt/conda/bin/conda", "run", "-n", "reltr", "/bin/bash", "-c"]
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]