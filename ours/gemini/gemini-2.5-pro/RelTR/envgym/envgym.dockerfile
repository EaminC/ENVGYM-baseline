# Use a Miniconda base image for a pre-configured Conda environment.
FROM continuumio/miniconda3:latest

# Set the shell to bash for all subsequent commands.
SHELL ["/bin/bash", "-c"]

# Define the root directory for the project.
ARG PROJECT_ROOT=/home/cc/EnvGym/data
WORKDIR ${PROJECT_ROOT}

# Install essential system-level dependencies.
# - git: For cloning the source code repository.
# - procps: Provides 'nproc' utility to determine the number of CPU cores for parallel builds.
# - unzip: For extracting dataset archives.
# - build-essential: Provides compilers (gcc, g++) and build tools (make) needed for C/C++ extensions.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    procps \
    unzip \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the RelTR source code repository.
RUN git clone https://github.com/yrcong/RelTR.git

# Set the working directory to the repository root.
WORKDIR ${PROJECT_ROOT}/RelTR

# Create the specified Conda environment with Python 3.6.
RUN conda create -n reltr python=3.6 -y

# Install dependencies in separate, sequential steps to improve dependency resolution.
# 1. Install PyTorch and Torchvision.
RUN conda run -n reltr conda install -y pytorch==1.6.0 torchvision==0.7.0 cpuonly -c pytorch

# 2. Install remaining Conda packages.
RUN conda run -n reltr conda install -y matplotlib scipy=1.5.2

# 3. Install pip packages required for building other dependencies.
RUN conda run -n reltr pip install cython numpy

# 4. Ensure setuptools is up-to-date before installing from source.
RUN conda run -n reltr pip install --upgrade setuptools

# 5. Install git into the conda environment so pip can use it to clone repositories.
RUN conda run -n reltr conda install -y git

# 6. Install pycocotools from conda-forge to avoid compilation issues.
RUN conda run -n reltr conda install -y -c conda-forge pycocotools

# Switch the default SHELL to execute subsequent commands within the 'reltr' environment.
# This simplifies the following build steps by avoiding repeated 'conda run' calls.
SHELL ["conda", "run", "-n", "reltr", "/bin/bash", "-c"]

# Compile the custom helper operations using the provided build script.
RUN cd lib/fpn && sh make.sh

# Install gdown, a utility for downloading large files from Google Drive.
RUN pip install gdown

# Create the checkpoint directory and download the pre-trained models.
RUN mkdir ckpt && \
    gdown --id 1id6oD_iwiNDD6HyCn2ORgRTIKkPD3tUD -O ckpt/checkpoint0149.pth && \
    gdown --id 1pcoUnR0XWsvM9lJZ5f93N5TKHkLdjtnb -O ckpt/checkpoint0149_oi.pth

# Create the directory structure for datasets.
# NOTE: The large image datasets are NOT included in this image. They should be
# mounted as volumes at runtime to keep the image size manageable.
# e.g., docker run -v /path/to/vg/images:${PROJECT_ROOT}/RelTR/data/vg/images ...
RUN mkdir -p data/vg/images && \
    mkdir -p data/oi/images

# Download and unpack the Visual Genome (VG) annotations.
RUN gdown --id 1aGwEu392DiECGdvwaYr-LgqGLmWhn8yD -O vg_annotations.zip && \
    unzip vg_annotations.zip -d data/vg/ && \
    rm vg_annotations.zip

# Reset the shell back to the default for the final CMD/ENTRYPOINT instructions.
SHELL ["/bin/bash", "-c"]

# Configure the bash profile to automatically activate the 'reltr' conda environment
# upon starting an interactive shell, providing a ready-to-use environment.
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate reltr" >> ~/.bashrc && \
    echo "echo 'Welcome to the RelTR environment. Conda environment \"reltr\" is now active.'" >> ~/.bashrc

# Set the final working directory again to ensure it's the default on container start.
WORKDIR ${PROJECT_ROOT}/RelTR

# Start a bash shell when the container runs. The .bashrc configuration will
# automatically set up the correct Conda environment.
CMD ["/bin/bash"]