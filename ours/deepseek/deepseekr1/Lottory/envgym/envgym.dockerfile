FROM python:3.7

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libpng-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Create virtual environment
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install dependencies
RUN pip install --upgrade pip
RUN pip install \
    torch==1.2.0+cpu \
    torchvision==0.4.0+cpu \
    numpy==1.17.2 \
    matplotlib==3.1.1 \
    pandas==0.25.1 \
    seaborn==0.9.0 \
    scipy==1.3.1 \
    tqdm==4.36.1 \
    Pillow==6.2.0 \
    cycler \
    kiwisolver \
    pyparsing \
    python-dateutil \
    pytz \
    six \
    -f https://download.pytorch.org/whl/torch_stable.html

# Install tensorboardX separately with compatible protobuf
RUN pip install tensorboardX==1.8 protobuf==3.20.0

# Verification commands
RUN python -c "import torch; print(f'PyTorch: {torch.__version__} (expected 1.2.0)')"
RUN python -c "import torchvision; print(f'torchvision: {torchvision.__version__} (expected 0.4.0)')"
RUN python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()} (expected False)')"
RUN python -c "import pandas; print('pandas verified')"
RUN python -c "import seaborn; print('seaborn verified')"
RUN python -c "import tensorboardX; print('tensorboardX verified')"

CMD ["/bin/bash"]