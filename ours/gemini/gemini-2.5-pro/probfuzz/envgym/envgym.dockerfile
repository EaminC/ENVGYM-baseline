# Use Ubuntu 18.04 as the base image.
FROM ubuntu:18.04

# Set environment variables to prevent interactive prompts.
ENV DEBIAN_FRONTEND=noninteractive

# Define the working directory.
WORKDIR /home/cc/EnvGym/data/probfuzz

# Install system dependencies and Python 2.
# Added software-properties-common as requested.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python2.7 \
    python2.7-dev \
    python-pip \
    bc \
    wget \
    ca-certificates \
    dos2unix \
    software-properties-common && \
    pip2 install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Copy the project files into the working directory.
COPY . .

# Fix line endings and make all shell scripts executable recursively.
# This prevents "command not found" errors due to DOS line endings or missing execute permissions.
RUN find . -type f -name "*.sh" -exec dos2unix {} + && \
    find . -type f -name "*.sh" -exec chmod +x {} +

# Install OpenJDK 8 using the system package manager.
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Python deep learning frameworks using pip2.
RUN pip2 install --no-cache-dir \
    torch==0.4.0 -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    pip2 install --no-cache-dir tensorflow==1.5.0

# Execute the main installation script.
RUN ./install.sh

# Step 5 & 6: Initial Test Run & Verify Metric Scripts
RUN ./probfuzz.py 1 && \
    metrics/mlr_smape.sh output/progs*/prob_rand_1 stan && \
    metrics/mlr_smape.sh output/progs*/prob_rand_1 edward && \
    metrics/mlr_smape.sh output/progs*/prob_rand_1 pyro

# Step 7: Full Run & Summary
# RUN ./probfuzz.py 5
# RUN ./summary.sh -d output/progs* -m mlr_smape

# Set the final command to launch an interactive bash shell.
CMD ["/bin/bash"]