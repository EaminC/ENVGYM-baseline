# CUDA + Python base image
FROM nvidia/cuda:11.1-cudnn8-runtime-ubuntu20.04

# Install basic system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.8 python3-pip python3.8-dev \
    git build-essential cython pkg-config \
    libjpeg-dev libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Set python alternatives (ensure python3 points to 3.8)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Install Python dependencies
RUN pip3 install --upgrade pip
RUN pip3 install torch==1.6.0 torchvision==0.7.0 matplotlib scipy cython numpy Pillow \
    git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI

# Set workdir and copy repo
WORKDIR /workspace
COPY . /workspace

# Build Cython extension for evaluation
RUN cd lib/fpn && bash make.sh

# Default to bash at workspace root
CMD ["/bin/bash"]
