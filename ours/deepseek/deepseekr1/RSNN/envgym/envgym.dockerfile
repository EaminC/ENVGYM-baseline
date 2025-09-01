FROM python:3.10.12-slim-bullseye

RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libsndfile1 \
    libhdf5-dev \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --upgrade pip

WORKDIR /app
COPY . .

RUN mkdir -p /home/cc/EnvGym/data/RSNN/output \
    && mkdir -p /home/cc/EnvGym/data/RSNN/datasets \
    && mkdir -p /conf/data

RUN echo "hydra:" > /conf/config.yaml \
    && echo "  run:" >> /conf/config.yaml \
    && echo "    dir: /home/cc/EnvGym/data/RSNN/output" >> /conf/config.yaml

RUN echo "data_dir: /home/cc/EnvGym/data/RSNN/datasets" > /conf/data/data-default.yaml

RUN pip install --no-cache-dir \
    torch==2.0.1 \
    torchvision==0.15.2 \
    torchaudio==2.0.2 \
    --index-url https://download.pytorch.org/whl/cpu

# Split installation steps for better error isolation
RUN sed -i '/fmi-basel\/stork/d; /randman/d' requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# Configure git to avoid warnings
RUN git config --global user.email "docker@example.com" \
    && git config --global user.name "Docker"

# Install packages with retry mechanism
RUN for i in {1..5}; do \
        pip install --no-cache-dir git+https://github.com/meistero/Stork.git@40c68fe#egg=stork && break || sleep 5; \
    done

RUN for i in {1..5}; do \
        pip install --no-cache-dir git+https://github.com/IGITUGraz/randman.git#egg=randman && break || sleep 5; \
    done

ENV OMP_NUM_THREADS=96

CMD ["/bin/bash"]