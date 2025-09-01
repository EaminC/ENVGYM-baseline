FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/TabPFN

COPY . .

RUN git submodule update --init --recursive

RUN python -m venv venv
ENV PATH="/home/cc/EnvGym/data/TabPFN/venv/bin:$PATH"

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -e ".[dev]"

RUN echo '# --- TabPFN Application Settings (parsed by src/tabpfen/settings.py) ---' > .env && \
    echo 'TABPFN_MODEL_CACHE_DIR="./.model_cache"' >> .env && \
    echo 'TABPFN_ALLOW_CPU_LARGE_DATASET=true' >> .env && \
    echo 'FORCE_CONSISTENCY_TESTS=true' >> .env && \
    echo 'CI=false' >> .env && \
    echo '# --- External Tool & Test Harness Settings ---' >> .env && \
    echo 'TABPFN_EXCLUDE_DEVICES="mps"' >> .env

RUN python scripts/download_all_models.py

CMD ["/bin/bash"]