FROM continuumio/miniconda3

# Set working directory
WORKDIR /RelTR

# Copy the entire repository
COPY . .

# Create conda environment
RUN conda create -n reltr python=3.6 && \
    conda run -n reltr pip install torch==1.6.0 torchvision==0.7.0 \
    matplotlib scipy \
    'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# Compile intersection code
RUN conda run -n reltr bash -c "cd lib/fpn && sh make.sh"

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]

# Set default shell to bash with conda environment activated
CMD ["conda", "run", "-n", "reltr", "/bin/bash"]