FROM python:3.8-slim

RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN python -m venv seed_gnn_env
ENV PATH="/workspace/seed_gnn_env/bin:$PATH"

RUN pip install --upgrade pip

RUN pip install torch==2.0.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

RUN pip install torch-scatter==2.1.1+pt20cpu torch-cluster==1.6.1+pt20cpu torch-spline-conv==1.2.2+pt20cpu torch-sparse==0.6.17+pt20cpu -f https://data.pyg.org/whl/torch-2.0.0+cpu.html

RUN pip install torch-geometric==2.3.1

RUN pip install torchvision==0.15.1+cpu torchaudio==2.0.1+cpu -f https://download.pytorch.org/whl/torch_stable.html

RUN pip install numpy==1.24.4 pandas==2.0.3 ogb==1.3.6

COPY . /workspace/SEED-GNN

WORKDIR /workspace/SEED-GNN

RUN mkdir -p data \
    output/results \
    output/edit_ckpts \
    ckpts \
    results

ENV CUDA_VISIBLE_DEVICES=""
ENV OMP_NUM_THREADS=4

RUN pip freeze > environment_snapshot.txt

CMD ["/bin/bash"]