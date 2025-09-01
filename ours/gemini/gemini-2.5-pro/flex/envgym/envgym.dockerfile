FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /home/cc/EnvGym/data/flex

# Install system dependencies in a single layer to optimize caching and reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core build and utility tools
    build-essential \
    git \
    cmake \
    clang \
    curl \
    swig \
    subversion \
    pkg-config \
    ca-certificates \
    # Media, Graphics, and Audio libraries
    portaudio19-dev \
    ffmpeg \
    xvfb \
    x11vnc \
    mesa-utils \
    libgl1-mesa-dev \
    libsdl-image1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-ttf2.0-dev \
    libsdl1.2-dev \
    libsmpeg-dev \
    libportmidi-dev \
    libswscale-dev \
    libavformat-dev \
    libavcodec-dev \
    libfreetype6-dev \
    libasound2-dev \
    libjack-dev \
    libsndfile1-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-ttf-dev \
    libsdl2-gfx-dev \
    libdirectfb-dev \
    libst-dev \
    libsdl-sge-dev \
    # Math and science libraries
    libgmp3-dev \
    libopenmpi-dev \
    libeigen3-dev \
    libboost-all-dev \
    # Geospatial libraries
    gdal-bin \
    libgdal-dev \
    # Database clients
    default-libmysqlclient-dev \
    libpq-dev \
    mysql-server && \
    # Clean up apt cache
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary symbolic links
RUN if [ -e /usr/include/locale.h ] && [ ! -e /usr/include/xlocale.h ]; then ln -s /usr/include/locale.h /usr/include/xlocale.h; fi && \
    if [ -e /usr/include/eigen3/Eigen ] && [ ! -e /usr/include/Eigen ]; then ln -s /usr/include/eigen3/Eigen /usr/include/Eigen; fi

# Install Miniconda
ENV CONDA_DIR /opt/conda
RUN curl -sL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o miniconda.sh && \
    rm -rf $CONDA_DIR && \
    bash miniconda.sh -b -p $CONDA_DIR && \
    rm miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy requirements file and install Python dependencies to leverage caching
COPY requirements.txt .

# Create conda environment.
RUN . $CONDA_DIR/etc/profile.d/conda.sh && \
    conda create -n flex-env python=3.8 -y

# Install R dependencies into the environment.
RUN conda run -n flex-env conda install -c conda-forge -y r-base r-eva

# Install Python dependencies into the environment.
RUN conda run -n flex-env pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

RUN mkdir projects

# Configure the shell to automatically activate the conda environment for interactive sessions
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate flex-env" >> ~/.bashrc

# Run setup script to download and configure the target project
RUN . $CONDA_DIR/etc/profile.d/conda.sh && conda activate flex-env && \
    chmod +x tool/scripts/general_setup.sh && \
    bash -x tool/scripts/general_setup.sh ../../projects coax-dev/coax local d169c93

# Run verification test to confirm environment setup
RUN . $CONDA_DIR/etc/profile.d/conda.sh && conda activate flex-env && \
    python tool/boundschecker.py -r coax -test test_update -file coax/coax/experience_replay/_prioritized_test.py -line 137 -conda coax -deps "numpy" -bc

WORKDIR /home/cc/EnvGym/data/flex
CMD ["/bin/bash"]