FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    sudo \
    libsmpeg-dev \
    subversion \
    libportmidi-dev \
    ffmpeg \
    libswscale-dev \
    libavformat-dev \
    libavcodec-dev \
    libfreetype6-dev \
    libsdl-image1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-ttf2.0-dev \
    libsdl1.2-dev \
    libasound2-dev \
    libjack-dev \
    portaudio19-dev \
    libsndfile1-dev \
    pkg-config \
    libgmp3-dev \
    libopenmpi-dev \
    libgl1-mesa-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-ttf-dev \
    libsdl2-gfx-dev \
    libboost-all-dev \
    libdirectfb-dev \
    libst-dev \
    mesa-utils \
    xvfb \
    x11vnc \
    libsdl-sge-dev \
    libmysqlclient-dev \
    libmariadbclient-dev \
    libpq-dev \
    gdal-bin \
    libgdal-dev \
    clang \
    curl \
    swig \
    mysql-server \
    python3.6 \
    python3.6-dev \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

# Copy whole repo source into container
COPY . /workdir

# Install python dependencies
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

# Install the repo as editable
RUN pip3 install -e .

CMD ["/bin/bash"]
