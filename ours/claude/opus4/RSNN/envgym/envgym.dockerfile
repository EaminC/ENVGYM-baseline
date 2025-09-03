FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    build-essential \
    ffmpeg \
    libhdf5-dev \
    libsndfile1-dev \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3.10-distutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/RSNN

RUN python3.10 -m ensurepip \
    && python3.10 -m pip install --upgrade pip setuptools wheel

COPY requirements.txt .

RUN sed -i 's|git+https://github.com/fmi-basel/stork.git@40c68fe|git+https://github.com/fmi-basel/stork.git@40c68fe#egg=stork|g' requirements.txt

RUN python3.10 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
    && python3.10 -m pip install -r requirements.txt

RUN mkdir -p data \
    && mkdir -p output \
    && mkdir -p notebooks \
    && mkdir -p matData \
    && mkdir -p .hydra \
    && mkdir -p models/snnTorch \
    && mkdir -p pretrained_models/tinyRSNN/loco \
    && mkdir -p pretrained_models/tinyRSNN/indy \
    && mkdir -p pretrained_models/bigRSNN/loco \
    && mkdir -p pretrained_models/bigRSNN/indy \
    && mkdir -p checkpoints \
    && mkdir -p multirun \
    && mkdir -p conf/data \
    && mkdir -p conf/hydra \
    && mkdir -p conf/initializer \
    && mkdir -p conf/evaluation \
    && mkdir -p conf/plotting \
    && mkdir -p conf/model \
    && mkdir -p conf/training

COPY . .

RUN if [ -f "conf/defaults.yaml" ]; then \
    sed -i 's/device: "cuda"/device: "cpu"/g' conf/defaults.yaml; \
    fi && \
    if [ -f "conf/evaluate.yaml" ]; then \
    sed -i 's/device: "cuda"/device: "cpu"/g' conf/evaluate.yaml; \
    fi && \
    if [ -f "conf/data/data-default.yaml" ]; then \
    sed -i 's|data_dir:.*|data_dir: /home/cc/EnvGym/data/RSNN/data|g' conf/data/data-default.yaml; \
    fi

RUN echo 'DATA_DIR=/home/cc/EnvGym/data/RSNN/data' > .env \
    && echo 'OUTPUT_DIR=/home/cc/EnvGym/data/RSNN/output' >> .env \
    && echo 'MODEL_DIR=/home/cc/EnvGym/data/RSNN/models' >> .env \
    && echo 'PYTHONPATH=/home/cc/EnvGym/data/RSNN' >> .env \
    && echo 'TORCH_DTYPE=float32' >> .env \
    && echo 'NB_WORKERS=2' >> .env \
    && echo 'PRETRAINED_MODELS_DIR=/home/cc/EnvGym/data/RSNN/pretrained_models' >> .env

RUN echo 'pytest' > requirements-dev.txt \
    && echo 'jupyter' >> requirements-dev.txt \
    && echo 'ipykernel' >> requirements-dev.txt \
    && echo 'black' >> requirements-dev.txt \
    && echo 'flake8' >> requirements-dev.txt \
    && python3.10 -m pip install -r requirements-dev.txt

RUN if [ ! -f ".gitignore" ]; then \
    echo 'data/*' > .gitignore \
    && echo '**/__pycache__/**' >> .gitignore \
    && echo '**/matData/**' >> .gitignore \
    && echo '*.svg' >> .gitignore \
    && echo '*.ods' >> .gitignore \
    && echo '**/*.code-workspace' >> .gitignore \
    && echo 'output/*' >> .gitignore \
    && echo 'notebooks/*' >> .gitignore \
    && echo '.vscode/*' >> .gitignore \
    && echo 'models/*' >> .gitignore \
    && echo '.env' >> .gitignore \
    && echo '*.pyc' >> .gitignore \
    && echo '*.h5' >> .gitignore \
    && echo '*.mat' >> .gitignore \
    && echo '*.xlsx' >> .gitignore \
    && echo '/outputs/' >> .gitignore \
    && echo '.hydra/' >> .gitignore \
    && echo 'multirun/' >> .gitignore \
    && echo 'pretrained_models/*' >> .gitignore \
    && echo 'checkpoints/*' >> .gitignore; \
    fi

ENV PYTHONPATH=/home/cc/EnvGym/data/RSNN
ENV PATH=/usr/bin/python3.10:$PATH

CMD ["/bin/bash"]