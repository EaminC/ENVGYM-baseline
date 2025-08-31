# Start from official CUDA-enabled PyTorch image
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Basic setup
WORKDIR /workspace
COPY . /workspace

# Fix for timezone and general OS utilities
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata git nano ffmpeg graphviz python3-pip python3-dev && \
    ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && echo "America/Chicago" > /etc/timezone && \
    apt-get clean

# Install torch-geometric and its extras
RUN pip install --upgrade pip wheel

# Pinned install for pyG and all requirements
RUN pip install torch-geometric==2.3.1 torchvision==0.15.1 torchaudio==2.0.1 torch-spline-conv==1.2.2 numpy==1.24.4 pandas==2.0.3 ogb==1.3.6

# These need a separate extra install step due to their wheels
RUN pip install torch-scatter==2.1.1 torch-cluster==1.6.1 torch-spline-conv==1.2.2 torch-sparse==0.6.17 -f https://data.pyg.org/whl/torch-2.0.0+cu117.html

# Install remaining requirements
RUN pip install -r requirements.txt || true

# Entrypoint puts user at Bash in /workspace
WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
