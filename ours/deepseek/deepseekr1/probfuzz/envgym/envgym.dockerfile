FROM python:3.7-buster

ENV DEBIAN_FRONTEND=noninteractive

RUN for i in 1 2 3; do \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            git \
            nodejs \
            default-jre \
            ca-certificates \
        && break || sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/cc/EnvGym/data/probfuzz
WORKDIR /home/cc/EnvGym/data/probfuzz
COPY . ./probfuzz
WORKDIR /home/cc/EnvGym/data/probfuzz/probfuzz

COPY <<EOF requirements.txt
pystan==2.19.1.1
edward==1.3.5
pyro-ppl==1.8.0
torch==1.12.1+cpu
tensorflow-cpu==1.15.0
antlr4-python3-runtime==4.9.3
EOF

COPY <<EOF environment.sh
#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir -r requirements.txt
EOF

RUN chmod +x environment.sh && ./environment.sh
RUN venv/bin/python -c "import pystan, edward, pyro, torch, tensorflow; print('OK')"
RUN if [ -f install.sh ]; then chmod +x install.sh && ./install.sh; fi
RUN if [ -f install_java.sh ]; then chmod +x install_java.sh && ./install_java.sh; fi

RUN echo "source /home/cc/EnvGym/data/probfuzz/probfuzz/venv/bin/activate" >> /root/.bashrc

WORKDIR /home/cc/EnvGym/data/probfuzz/probfuzz
CMD ["/bin/bash"]