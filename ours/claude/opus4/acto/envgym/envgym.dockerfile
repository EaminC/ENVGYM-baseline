FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    git \
    curl \
    wget \
    ssh \
    xmlstarlet \
    jq \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --set python3 /usr/bin/python3.10

RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

RUN mkdir -p /go/bin /go/src /go/pkg

RUN go version && \
    go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://proxy.golang.org,direct

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    mv kustomize /usr/local/bin/

RUN curl https://bootstrap.pypa.io/get-pip.py | python3.10

WORKDIR /home/cc
RUN mkdir -p /home/cc/EnvGym/data

WORKDIR /home/cc/EnvGym/data
RUN git clone https://github.com/xlab-uiuc/acto.git

WORKDIR /home/cc/EnvGym/data/acto

RUN go install github.com/wadey/gocovmerge@latest || true

RUN python3 -m venv .venv && \
    . .venv/bin/activate && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install pip-tools==7.3.0 wheel==0.42.0

RUN . .venv/bin/activate && \
    python3 -m pip install pre-commit==3.6.0 \
    black==24.10.0 \
    isort==5.13.2 \
    mypy==1.7.1 \
    pylint==3.0.3 \
    pytest==7.4.3 \
    pytest-cov==4.1.0 \
    ansible-core==2.17.5 \
    kubernetes==31.0.0 \
    pydantic==2.5.2 \
    docker==6.1.3 \
    deepdiff==6.3.1 \
    jsonschema==4.17.3 \
    pandas==2.0.3 \
    prometheus-client==0.19.0 \
    PyYAML \
    openapi-spec-validator \
    openapi-schema-validator

RUN . .venv/bin/activate && \
    ansible-galaxy collection install ansible.posix community.general

RUN mkdir -p /home/cc/.kube \
    /home/cc/EnvGym/data/acto/test \
    /home/cc/EnvGym/data/acto/data \
    /home/cc/EnvGym/data/acto/.mypy_cache \
    /home/cc/EnvGym/data/acto/.pytest_cache \
    /home/cc/EnvGym/data/acto/htmlcov \
    /home/cc/EnvGym/data/acto/ssa/taint_analysis_results \
    /home/cc/EnvGym/data/acto/scripts/field_count/output \
    /home/cc/EnvGym/data/acto/scripts/field_count/test \
    /home/cc/EnvGym/data/acto/scripts/pruning_analysis \
    /home/cc/EnvGym/data/acto/scripts/csv_reports \
    /home/cc/workdir/acto \
    /home/cc/.ansible \
    /home/cc/.ssh

RUN echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf && \
    echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf

WORKDIR /home/cc/EnvGym/data/acto/acto/k8s_util/lib
RUN if [ -f Makefile ]; then make clean && make; fi

WORKDIR /home/cc/EnvGym/data/acto/ssa
RUN if [ -f Makefile ]; then make clean && make; fi

WORKDIR /home/cc/EnvGym/data/acto/scripts/field_count
RUN if [ -f go.mod ]; then go mod download && go build -o field_count .; fi

WORKDIR /home/cc/EnvGym/data/acto

RUN touch /home/cc/EnvGym/data/acto/.env && \
    echo "export PATH=/home/cc/EnvGym/data/acto/.venv/bin:\$PATH" >> ~/.bashrc && \
    echo "source /home/cc/EnvGym/data/acto/.venv/bin/activate" >> ~/.bashrc

ENV PATH="/home/cc/EnvGym/data/acto/.venv/bin:${PATH}"

CMD ["/bin/bash"]