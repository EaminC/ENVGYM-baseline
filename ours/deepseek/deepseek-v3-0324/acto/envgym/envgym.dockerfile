# syntax=docker/dockerfile:1.4
FROM golang:latest AS go-builder

RUN apt-get update && apt-get install -y \
    wget \
    make \
    xmlstarlet \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-linux-amd64 \
    && chmod +x kind-linux-amd64 \
    && mv kind-linux-amd64 /usr/local/bin/kind

RUN wget https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl

RUN wget https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz \
    && tar -zxvf helm-v3.12.0-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-v3.12.0-linux-amd64.tar.gz

RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz \
    && tar -zxvf kustomize_v4.5.7_linux_amd64.tar.gz \
    && mv kustomize /usr/local/bin/kustomize \
    && rm kustomize_v4.5.7_linux_amd64.tar.gz

RUN wget https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz \
    && tar -zxvf helm-docs_1.11.0_Linux_x86_64.tar.gz \
    && mv helm-docs /usr/local/bin/helm-docs \
    && rm helm-docs_1.11.0_Linux_x86_64.tar.gz

RUN go install github.com/wadey/gocovmerge@latest

FROM python:3.10-slim

COPY --from=go-builder /usr/local/bin/kind /usr/local/bin/kind
COPY --from=go-builder /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=go-builder /usr/local/bin/helm /usr/local/bin/helm
COPY --from=go-builder /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=go-builder /usr/local/bin/helm-docs /usr/local/bin/helm-docs
COPY --from=go-builder /go/bin/gocovmerge /usr/local/bin/gocovmerge

RUN apt-get update && apt-get install -y \
    wget \
    make \
    git \
    xmlstarlet \
    python3-pip \
    python3-venv \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN pip install ansible
RUN ansible-galaxy collection install ansible.posix community.general

WORKDIR /home/cc/EnvGym/data/acto
COPY . .

RUN python3 -m venv /home/cc/EnvGym/data/acto/venv
RUN /home/cc/EnvGym/data/acto/venv/bin/pip install --upgrade pip
RUN /home/cc/EnvGym/data/acto/venv/bin/pip install -r requirements.txt

RUN mkdir -p /home/cc/EnvGym/data/acto/k8s_util/lib/ \
    && mkdir -p /home/cc/EnvGym/data/acto/ssa/ \
    && mkdir -p /tmp/profile/ \
    && mkdir -p /tmp/acto-cloudlab/scripts/ansible/ \
    && mkdir -p ~/.ssh/

ENV PATH="/home/cc/EnvGym/data/acto/venv/bin:${PATH}"
WORKDIR /home/cc/EnvGym/data/acto

CMD ["/bin/bash"]