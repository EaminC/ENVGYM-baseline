FROM ubuntu:18.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHON_VERSION=3.7 \
    CONDA_DIR=/opt/conda \
    PATH=$CONDA_DIR/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda with proper permissions
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh && \
    ln -s $CONDA_DIR/bin/conda /usr/bin/conda && \
    $CONDA_DIR/bin/conda init bash && \
    $CONDA_DIR/bin/conda config --set auto_activate_base false

# Create conda environment
RUN conda create -y -n envgym python=$PYTHON_VERSION && \
    conda clean -afy

# Copy application files
COPY . /sixthsense
WORKDIR /sixthsense

# Install Python requirements
RUN conda run -n envgym pip install --no-cache-dir -r requirements.txt && \
    conda run -n envgym pip install --no-cache-dir \
    scikit-learn \
    numpy \
    matplotlib \
    pandas \
    jsonpickle \
    nearpy \
    treeinterpreter \
    cleanlab

# Create required directories
RUN mkdir -p data/sixthsense/plots \
    data/sixthsense/models \
    data/sixthsense/results

# Set entrypoint
ENTRYPOINT ["conda", "run", "-n", "envgym", "/bin/bash"]