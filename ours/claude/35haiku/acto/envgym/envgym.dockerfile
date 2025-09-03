FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y \
    wget curl git software-properties-common \
    build-essential gcc make cmake \
    inotify-tools ssh openssh-client \
    xmlstarlet ca-certificates gnupg \
    python3 python3-pip python3-venv \
    golang-go

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Kubernetes tools
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install Kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv kind /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Python dependencies
RUN pip3 install --upgrade pip \
    && pip3 install pip-tools pre-commit ansible-core==2.17.5 Jinja2==3.1.4

# Go tools with error handling
RUN mkdir -p /go/bin \
    && export GOPATH=/go \
    && export PATH=$PATH:$GOPATH/bin \
    && go install golang.org/x/tools/cover@latest || true \
    && go install github.com/wadey/gocovmerge@latest || true

# SSH and security setup
RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh

# Performance and system tuning
RUN echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf \
    && sysctl -p

# Set working directory
WORKDIR /acto

# Copy repository contents
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Default command
CMD ["/bin/bash"]