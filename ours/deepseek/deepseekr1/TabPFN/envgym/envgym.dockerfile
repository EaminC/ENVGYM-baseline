FROM python:3.9-slim-bullseye
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir \
    torch==1.13.1+cpu \
    torchvision==0.14.1+cpu \
    torchaudio==0.13.1 \
    -f https://download.pytorch.org/whl/cpu/torch_stable.html \
    tabpfn \
    scikit-learn \
    xgboost
COPY . .
ENV OMP_NUM_THREADS=4
ENV PYTHONUNBUFFERED=1
CMD ["/bin/bash"]