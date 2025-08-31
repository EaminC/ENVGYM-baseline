FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3.8-venv \
    python3.8-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

WORKDIR /app

COPY . /app

RUN python3 -m pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ["/bin/bash"]
