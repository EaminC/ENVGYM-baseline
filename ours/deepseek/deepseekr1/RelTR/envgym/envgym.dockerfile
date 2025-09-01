FROM ubuntu:18.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install system dependencies with cleanup
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    unzip \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with retries using archive URL
RUN wget --tries=3 --retry-connrefused --waitretry=30 https://repo.anaconda.com/archive/Miniconda3-py36_4.10.3-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /miniconda \
    && rm miniconda.sh
ENV PATH="/miniconda/bin:$PATH"

# Install Python dependencies
RUN conda install -y python=3.6 \
    && conda install -y pytorch==1.6.0 torchvision==0.7.0 cpuonly -c pytorch \
    && conda install -y matplotlib scipy=1.5.2 \
    && pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' \
    && pip install cython numpy gdown

# Create directory structure
RUN mkdir -p /workspace/data/vg/images \
    /workspace/data/oi/images \
    /workspace/data/oi/raw_annotations \
    /workspace/ckpt \
    /workspace/demo

# Set working directory
WORKDIR /workspace

# Copy repository code
COPY . .

# Compile CPU-only components
RUN cd lib/fpn \
    && sh make.sh \
    && cd box_intersections_cpu \
    && python setup.py build_ext --inplace

# Verify CPU installation
RUN python -c "import torch; print(torch.__version__); assert not torch.cuda.is_available()"

# Set default command
CMD ["/bin/bash"]