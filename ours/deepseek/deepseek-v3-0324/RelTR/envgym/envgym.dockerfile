FROM continuumio/miniconda3:4.9.2

# Update package lists with retry logic
RUN apt-get update -y || apt-get update -y

# Install basic dependencies one by one with error handling
RUN apt-get install -y --no-install-recommends ca-certificates && \
    apt-get install -y --no-install-recommends git && \
    apt-get install -y --no-install-recommends build-essential

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Create conda environment
RUN conda create -n reltr python=3.6 -y
ENV PATH /opt/conda/envs/reltr/bin:$PATH

# Install Python packages with conda in separate steps
RUN /bin/bash -c "source activate reltr && conda install -y pytorch==1.6.0 torchvision==0.7.0 cpuonly -c pytorch"
RUN /bin/bash -c "source activate reltr && conda install -y matplotlib scipy cython numpy"
RUN /bin/bash -c "source activate reltr && pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'"

# Set up working directory
WORKDIR /workspace

# Create required directories
RUN mkdir -p data/vg/images data/oi/images ckpt

# Copy repository contents
COPY . .

# Compile extensions in separate steps
RUN /bin/bash -c "source activate reltr && cd lib/fpn && sh make.sh"
RUN /bin/bash -c "source activate reltr && cd lib/fpn/box_intersections_cpu && python setup.py build_ext --inplace"

# Set default command
CMD ["/bin/bash"]