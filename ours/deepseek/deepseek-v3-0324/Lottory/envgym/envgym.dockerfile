FROM python:3.7-slim

RUN apt-get update && apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /Lottery-Ticket-Hypothesis-in-Pytorch
RUN git clone https://github.com/rahulvigneswaran/Lottery-Ticket-Hypothesis-in-Pytorch.git ./

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir torch==1.2.0+cpu torchvision==0.4.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

RUN mkdir -p /saves /plots

COPY main.py ./
COPY utils.py ./
COPY combine_plots.py ./
COPY README.md ./
COPY archs ./archs

RUN python -c "import torch; print(torch.device('cpu'))" && \
    python -c "import pandas, seaborn, tensorboardX; print('All imports successful')"

CMD ["/bin/bash"]