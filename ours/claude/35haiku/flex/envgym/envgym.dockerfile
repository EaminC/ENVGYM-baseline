FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    git \
    build-essential \
    libsdl2-dev \
    libsdl-sound1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-image1.2-dev \
    libpq-dev \
    libmysqlclient-dev \
    gdal-bin \
    libgdal-dev \
    python3-pip \
    software-properties-common \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install R
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
    apt-get update && \
    apt-get install -y r-base r-base-dev

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

ENV PATH /opt/conda/bin:$PATH

# Initialize conda
RUN /opt/conda/bin/conda init bash

# Set up environment and install requirements
WORKDIR /flex

# Copy project files
COPY . .

# Create conda environment and install dependencies
RUN /bin/bash -c "\
    source /root/.bashrc && \
    conda create -n flex python=3.8 -y && \
    conda run -n flex pip install --no-cache-dir -r requirements.txt && \
    conda run -n flex R -e 'install.packages(c(\"eva\"), repos=\"https://cloud.r-project.org/\")' \
    "

# Default command to start bash in the project directory
ENTRYPOINT ["/bin/bash", "-c", "source /root/.bashrc && conda activate flex && cd /flex && /bin/bash"]