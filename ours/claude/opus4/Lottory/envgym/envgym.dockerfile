FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.7 \
    python3.7-dev \
    python3.7-distutils \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && \
    python3.7 get-pip.py && \
    rm get-pip.py

WORKDIR /home/cc/EnvGym/data/Lottory

RUN git clone https://github.com/rahulvigneswaran/Lottery-Ticket-Hypothesis-in-Pytorch.git . || true

RUN python3.7 -m pip install --upgrade pip

RUN python3.7 -m pip install torch==1.2.0+cpu torchvision==0.4.0+cpu -f https://download.pytorch.org/whl/torch_stable.html || \
    python3.7 -m pip install torch==1.2.0 torchvision==0.4.0

RUN python3.7 -m pip install numpy==1.17.2
RUN python3.7 -m pip install matplotlib==3.1.1
RUN python3.7 -m pip install tqdm==4.36.1
RUN python3.7 -m pip install pandas==0.25.1
RUN python3.7 -m pip install seaborn==0.9.0
RUN python3.7 -m pip install scipy==1.3.1
RUN python3.7 -m pip install tensorboardX==1.8
RUN python3.7 -m pip install Pillow==6.2.0
RUN python3.7 -m pip install cycler==0.10.0
RUN python3.7 -m pip install kiwisolver==1.1.0
RUN python3.7 -m pip install protobuf==3.9.2
RUN python3.7 -m pip install pyparsing==2.4.2
RUN python3.7 -m pip install python-dateutil==2.8.0
RUN python3.7 -m pip install pytz==2019.2
RUN python3.7 -m pip install six==1.12.0

RUN mkdir -p data dumps saves plots/lt/combined_plots plots/reinit runs

RUN echo "__pycache__/\n*.pyc\ndata/\ndumps/\nsaves/\nplots/\nruns/\n.DS_Store\n*.pth\n*.log" > .gitignore

RUN echo "import torch\nimport torchvision\nimport numpy\nimport matplotlib\nimport tqdm\nimport pandas\nimport seaborn\nimport scipy\nimport tensorboardX\nfrom PIL import Image\nprint('All imports successful')\nprint(f'PyTorch version: {torch.__version__}')\nprint(f'CUDA available: {torch.cuda.is_available()}')\nprint('Running in CPU-only mode')" > test_main.py

RUN echo "# Configuration settings\nDEVICE = 'cpu'\nBATCH_SIZE = 64\nLEARNING_RATE = 0.001\nEPOCHS = 10" > config.py

ENV PYTHONUNBUFFERED=1

CMD ["/bin/bash"]