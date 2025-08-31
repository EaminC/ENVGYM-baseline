FROM ubuntu:22.04

# Prevent interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=/opt/conda/bin:$PATH
WORKDIR /opt
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Copy repo
WORKDIR /app
COPY . /app

# Create environment with python 3.11 and pip
RUN conda create -y -n baleen_env python=3.11 && \
    /opt/conda/bin/conda clean -afy

# Activate environment and install pip
RUN /bin/bash -c "source activate baleen_env && python -m pip install --upgrade pip"

ENV PATH=/opt/conda/envs/baleen_env/bin:$PATH

WORKDIR /app

CMD ["/bin/bash"]
