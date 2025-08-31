FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-runtime

# Set working directory
WORKDIR /workspace/RelTR

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy the repository into the container
COPY . /workspace/RelTR

# Install Python dependencies
RUN pip install --no-cache-dir \
    torchvision==0.7.0 \
    matplotlib \
    scipy==1.5.2 \
    pycocotools \
    numpy

# Compile the FPN box intersection code
RUN cd /workspace/RelTR/lib/fpn && \
    sh make.sh || echo "Warning: FPN compilation might have failed"

# Set environment variables
ENV PYTHONPATH="/workspace/RelTR:${PYTHONPATH}"

# Default command - start bash shell
CMD ["/bin/bash"]