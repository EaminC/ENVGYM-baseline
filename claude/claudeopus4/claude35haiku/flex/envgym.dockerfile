FROM python:3.8-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    build-essential \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh

# Set path
ENV PATH /opt/conda/bin:$PATH

# Create a working directory
WORKDIR /flex

# Copy the entire repository
COPY . .

# Install R dependencies 
RUN conda install -c conda-forge r-base r-eva

# Install Python dependencies
RUN pip install -r requirements.txt

# Set the default command to bash
CMD ["/bin/bash"]