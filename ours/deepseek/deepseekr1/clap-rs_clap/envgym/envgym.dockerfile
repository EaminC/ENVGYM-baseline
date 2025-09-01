FROM rust:1.73.0-focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    build-essential \
    pkg-config \
    libssl-dev \
    curl \
    ca-certificates \
    python3.8 \
    python3.8-distutils && \
    git lfs install && \
    ln -s /usr/bin/python3.8 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://bootstrap.pypa.io/pip/3.8/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip install torch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cpu
RUN pip install numpy==1.24.3 transformers==4.30.2

WORKDIR /workspace
COPY . .
RUN cargo build --release

CMD ["/bin/bash"]