# Step 1: Base Image - Use Python 3.7 on a slim Debian distribution
FROM python:3.7-slim-buster

# Set environment variables for non-interactive installs and unbuffered python output
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Step 2: Install System Prerequisites
# Modify sources.list to use the Debian archive for the "buster" release, as it's no longer supported on the main mirrors.
# Then, install git to clone the repository.
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
           -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
           -e '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Set up the Working Directory and Clone the Project
WORKDIR /app
RUN git clone https://github.com/rahulvigneswaran/Lottery-Ticket-Hypothesis-in-Pytorch.git .

# Step 4: Install Python Dependencies
# Install packages from requirements.txt. This will install the CPU-only version of torch.
# --no-cache-dir reduces the image size.
RUN pip3 install --no-cache-dir -r requirements.txt

# Step 5: Verify the Python Environment
# Confirm that the correct torch version is installed and that it's a CPU-only build (CUDA not available)
RUN python3 -c "import torch; print(f'PyTorch version: {torch.__version__}'); assert torch.__version__ == '1.2.0', 'Torch version mismatch'; print(f'CUDA available: {torch.cuda.is_available()}'); assert not torch.cuda.is_available(), 'CUDA is available but should not be'"

# Step 6: Create Data and Output Directories and Pre-download Datasets
# Create directories where the datasets and script outputs will be stored.
RUN mkdir -p /data ./dumps ./plots ./runs ./saves
# The dataset pre-download step is commented out to allow for interactive debugging of the script failure.
# RUN python3 main.py --arch_type=fc1 --dataset=mnist --end_iter=1 && \
#     python3 main.py --arch_type=lenet5 --dataset=fashionmnist --end_iter=1 && \
#     python3 main.py --arch_type=lenet5 --dataset=cifar10 --end_iter=1 && \
#     python3 main.py --arch_type=resnet20 --dataset=cifar100 --end_iter=1

# Step 7: Final Configuration
# The repository is now installed and ready to use.
# Set the default command to start a bash shell in the working directory.
CMD ["/bin/bash"]