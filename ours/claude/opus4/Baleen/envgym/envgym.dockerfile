FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/micromamba/bin:$PATH
ENV MAMBA_ROOT_PREFIX=/opt/micromamba

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    systemd \
    sudo \
    tar \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone --recurse-submodules https://github.com/wonglkd/Baleen-FAST24.git . && \
    if [ ! -d "BCacheSim" ]; then echo "Error: BCacheSim not found"; exit 1; fi && \
    git submodule update --init --recursive

RUN mkdir -p data runs tmp notebooks/figs notebooks/paper-figs/figs \
    data/tectonic/201910/Region1 \
    tmp/example/201910_Region1_0_0.1 \
    runs/example/baleen/example/201910_Region1_0_0.1 \
    runs/example/rejectx \
    runs/example/baleen/prefetch_ml-on-partial-hit

RUN if [ ! -f data/.gitignore ]; then \
    echo -e '*\n!.gitignore\n!*.sh' > data/.gitignore; \
    fi

RUN if [ ! -f runs/.gitignore ]; then \
    echo -e '*\n.ipynb_checkpoints\n!.gitignore\n!config.json\n!*/' > runs/.gitignore; \
    fi

RUN mkdir -p /opt/micromamba/bin

RUN cd /tmp && \
    wget -q https://micro.mamba.pm/api/micromamba/linux-64/latest -O micromamba.tar.bz2 && \
    tar -xjf micromamba.tar.bz2 && \
    if [ -f bin/micromamba ]; then \
        mv bin/micromamba /opt/micromamba/bin/; \
    else \
        echo "Error: micromamba binary not found after extraction"; \
        exit 1; \
    fi && \
    chmod +x /opt/micromamba/bin/micromamba && \
    rm -rf /tmp/micromamba.tar.bz2 /tmp/bin

RUN /opt/micromamba/bin/micromamba create -y -n cachelib-py-3.11 python=3.11 --root-prefix /opt/micromamba

RUN if [ -f BCacheSim/install/env_cachelib-py-3.11.yaml ]; then \
        /opt/micromamba/bin/micromamba env update -y -n cachelib-py-3.11 -f BCacheSim/install/env_cachelib-py-3.11.yaml --root-prefix /opt/micromamba; \
    elif [ -f BCacheSim/install/requirements.txt ]; then \
        /opt/micromamba/bin/micromamba run -n cachelib-py-3.11 --root-prefix /opt/micromamba pip install -r BCacheSim/install/requirements.txt; \
    fi

RUN /opt/micromamba/bin/micromamba install -y -n cachelib-py-3.11 -c conda-forge jupyterlab --root-prefix /opt/micromamba

RUN chmod -R 755 /workspace

RUN echo '#!/bin/bash\n\
cd /workspace/data\n\
if [ ! -f "tectonic/201910/Region1/full_0_0.1.trace" ]; then\n\
    echo "Downloading trace files..."\n\
    if [ -f "get-tectonic.sh" ]; then\n\
        bash get-tectonic.sh\n\
    else\n\
        mkdir -p tectonic/201910/Region1\n\
        cd tectonic/201910/Region1\n\
        wget -q https://ftp.pdl.cmu.edu/pub/datasets/Baleen24/tectonic/201910/Region1/full_0_0.1.trace\n\
    fi\n\
fi\n\
cd /workspace' > /workspace/download_traces.sh && \
    chmod +x /workspace/download_traces.sh

RUN echo '#!/bin/bash\n\
export MAMBA_ROOT_PREFIX=/opt/micromamba\n\
export PATH=/opt/micromamba/bin:$PATH\n\
cd /workspace\n\
exec /opt/micromamba/bin/micromamba run -n cachelib-py-3.11 --root-prefix /opt/micromamba /bin/bash' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD []