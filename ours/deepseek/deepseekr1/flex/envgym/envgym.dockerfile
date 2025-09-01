FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update

# Install system dependencies
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    git build-essential curl cmake swig \
    libeigen3-dev libc6-dev \
    libsdl-image1.2-dev libsdl-ttf2.0-dev libsdl1.2-dev \
    subversion ffmpeg libswscale-dev libavformat-dev libavcodec-dev \
    libfreetype6-dev portaudio19-dev libsndfile1-dev pkg-config \
    libopenmpi-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev mesa-utils xvfb x11vnc \
    libpq-dev gdal-bin libgdal-dev

# Log architecture information
RUN uname -m && echo "Architecture: $(uname -m)"

# Verify installed packages
RUN dpkg -l | (grep -E 'libsdl|ffmpeg|portaudio|boost|gdal' || echo "No matching packages found")

# Clean up apt cache
RUN rm -rf /var/lib/apt/lists/*

# Create conditional symlinks
RUN [ -e /usr/include/locale.h ] && [ ! -e /usr/include/xlocale.h ] && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h || true
RUN [ -e /usr/include/eigen3/Eigen ] && [ ! -e /usr/include/Eigen ] && \
    ln -s /usr/include/eigen3/Eigen /usr/include/Eigen || true

# Install Miniconda
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Create symlink and set PATH
RUN ln -s /root/miniconda /root/anaconda3
ENV PATH="/root/miniconda/bin:$PATH"

# Verify conda
RUN bash -c "source /root/miniconda/etc/profile.d/conda.sh && conda --version"

# Create environment
RUN bash -c "source /root/miniconda/etc/profile.d/conda.sh && conda create -n fourier -c conda-forge --override-channels --strict-channel-priority python=3.8 -y"

# Install R dependencies
RUN bash -c "source /root/miniconda/etc/profile.d/conda.sh && \
    conda install -n fourier -c conda-forge r-base r-essentials -y"

# Verify environment
RUN bash -c "source /root/miniconda/etc/profile.d/conda.sh && \
    conda env list | grep fourier"

# Setup repository
WORKDIR /workspace
COPY . .

# Install Python dependencies
RUN bash -c "source /root/miniconda/etc/profile.d/conda.sh && \
    conda run -n fourier pip install --no-cache-dir -r requirements.txt"

# Create project directory
RUN mkdir -p /home/cc/EnvGym/data/flex/projects

# Setup test project
ARG COMMIT_HASH
RUN cd tool/scripts && \
    bash general_setup.sh /home/cc/EnvGym/data/flex/projects diana-hep/coax local "${COMMIT_HASH}"

# Default command
WORKDIR /workspace
CMD ["/root/miniconda/bin/conda", "run", "--no-capture-output", "-n", "fourier", "bash"]