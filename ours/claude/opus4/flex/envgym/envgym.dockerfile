FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libsdl-image1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-ttf2.0-dev \
    libsdl1.2-dev \
    libsmpeg-dev \
    subversion \
    libportmidi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libswscale-dev \
    libavformat-dev \
    libavcodec-dev \
    libfreetype6-dev \
    libasound2-dev \
    libjack-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    portaudio19-dev \
    libsndfile1-dev \
    pkg-config \
    libgmp3-dev \
    libopenmpi-dev \
    libeigen3-dev \
    cmake \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libgl1-mesa-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-ttf-dev \
    libsdl2-gfx-dev \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libdirectfb-dev \
    libst-dev \
    mesa-utils \
    xvfb \
    x11vnc \
    libsdl-sge-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libmysqlclient-dev \
    libpq-dev \
    gdal-bin \
    libgdal-dev \
    clang \
    swig \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/include/locale.h /usr/include/xlocale.h && \
    ln -sf /usr/include/eigen3/Eigen /usr/include/Eigen

RUN useradd -m -s /bin/bash cc
USER cc
WORKDIR /home/cc

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/cc/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/home/cc/miniconda3/bin:${PATH}"

RUN /home/cc/miniconda3/bin/conda init bash

SHELL ["/bin/bash", "-c"]

RUN /home/cc/miniconda3/bin/conda config --add channels conda-forge

RUN /home/cc/miniconda3/bin/conda create -n flex-env python=3.8 -y

RUN /home/cc/miniconda3/bin/conda run -n flex-env conda install -c conda-forge r-base r-eva -y

RUN /home/cc/miniconda3/bin/conda run -n flex-env conda install -y pip pytest pytest-timeout

RUN /home/cc/miniconda3/bin/conda run -n flex-env pip install arviz==0.6.1 rpy2==3.2.0 scipy==1.5.4

RUN /home/cc/miniconda3/bin/conda run -n flex-env pip install jax==0.2.9 jaxlib==0.1.61

RUN /home/cc/miniconda3/bin/conda run -n flex-env pip install astunparse numpy statsmodels hyperopt tabulate pandas diff-match-patch

RUN mkdir -p /home/cc/EnvGym/data/flex/{projects,tool/logs,tool/scripts/extra_deps,test_results,patches,diffs,build_logs,tool/scripts/data,tool/scripts/azure/results,obj}

WORKDIR /home/cc/EnvGym/data/flex

COPY --chown=cc:cc . .

RUN echo -e '.idea/\n*.pyc\n__pycache__\nvenv\nlogs/\ntool/scripts/data\n.vscode\nobj/\nprojects/\n*.tar.gz\nbuild_logs/\ntool/scripts/azure/results/' > .gitignore

RUN /home/cc/miniconda3/bin/conda run -n flex-env pip freeze > requirements-frozen.txt

RUN /home/cc/miniconda3/bin/conda env export -n flex-env > environment.yml

RUN echo "flex-env created on $(date)" > conda_environments.txt

RUN echo "source /home/cc/miniconda3/etc/profile.d/conda.sh && conda activate flex-env" >> /home/cc/.bashrc

CMD ["/bin/bash", "-l"]