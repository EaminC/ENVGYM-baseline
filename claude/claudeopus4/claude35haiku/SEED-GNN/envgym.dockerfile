FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the entire repository
COPY . /app

# Install Python dependencies
RUN pip install torch==2.0.0 \
    && pip install torch-scatter==2.1.1 torch-cluster==1.6.1 torch-spline-conv==1.2.2 torch-sparse==0.6.17 -f https://data.pyg.org/whl/torch-2.0.0+cu117.html \
    && pip install -r requirements.txt

# Default command
CMD ["/bin/bash"]