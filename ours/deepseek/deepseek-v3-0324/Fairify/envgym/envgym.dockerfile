FROM python:3.7-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/cc/EnvGym/data/Fairify

# Create directory structure
RUN mkdir -p data/adult data/bank data/german res/

# Download datasets
RUN wget -P data/adult https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data \
    && wget -P data/adult https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test \
    && wget -P data/adult https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.names \
    && wget -P data/bank https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip \
    && unzip data/bank/bank-additional.zip -d data/bank/ \
    && mv data/bank/bank-additional/bank-additional-full.csv data/bank/ \
    && mv data/bank/bank-additional/bank-additional-names.txt data/bank/ \
    && rm -rf data/bank/bank-additional data/bank/bank-additional.zip \
    && wget -P data/german https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.data \
    && wget -P data/german https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.doc

# Create virtual environment
RUN python -m pip install --upgrade pip \
    && python -m pip install virtualenv \
    && python -m virtualenv fenv

# Activate virtual environment and install Python packages
RUN . fenv/bin/activate \
    && pip install tensorflow-cpu==2.5.0 \
    && pip install z3-solver \
    && pip install aif360 \
    && pip install pandas

# Create documentation files
RUN touch INSTALL.md \
    && echo "CPU-only installation instructions:" >> INSTALL.md \
    && echo "This installation is configured for x86_64 CPU-only execution" >> INSTALL.md \
    && echo "TensorFlow GPU support is disabled" >> INSTALL.md

# Create test files
RUN touch test_cpu.py \
    && echo "import tensorflow as tf; assert not tf.test.is_gpu_available()" >> test_cpu.py \
    && touch test_arch.py \
    && echo "import os; assert os.uname().machine == 'x86_64'" >> test_arch.py

# Set environment variables
ENV PATH="/home/cc/EnvGym/data/Fairify/fenv/bin:$PATH"

# Set default command
CMD ["/bin/bash"]