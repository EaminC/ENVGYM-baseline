# Base image based on Ubuntu 20.04, as specified in the manual setup plan
FROM ubuntu:20.04

# Set non-interactive mode for package installations
ENV DEBIAN_FRONTEND=noninteractive

# Define Go version and environment variables
ENV GO_VERSION=1.20.5
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Step 1: Install system prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    gnupg \
    build-essential \
    git \
    curl \
    wget \
    lsb-release \
    sudo

# Step 2: Add PPA for Python 3.10
RUN add-apt-repository -y ppa:deadsnakes/ppa

# Step 3: Install Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-venv

# Install pip for python3.10 using the official bootstrap script
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Configure Python alternatives to make python3.10 the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Golang version 1.20.5
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Docker CLI client. The Docker daemon will be accessed via a mounted socket from the host.
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli

# Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory to the project path
WORKDIR /app

# Copy the project source code into the container
COPY . /app

# Step 4: Set Up Python Environment
# Create a virtual environment and install all dependencies from requirements-dev.txt
RUN python3 -m venv venv && \
    venv/bin/pip install -r requirements-dev.txt

# Activate the virtual environment for subsequent commands and the final shell
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Step 6 & 7: Install Kubernetes Tooling and other Go tools
RUN go install sigs.k8s.io/kind@v0.20.0
RUN go install github.com/wadey/gocovmerge@latest
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl
RUN curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    install minikube-linux-amd64 /usr/local/bin/minikube && \
    rm minikube-linux-amd64

# Step 8: Build Acto Project Core Components
RUN make

# Step 9: Build SSA module
WORKDIR /app/ssa
RUN go mod tidy && make analysis

# Step 10: Build Go utilities
WORKDIR /app/scripts/field_count
RUN go mod tidy && go build ./cmd/actoFieldCount/

# Return to the root project directory
WORKDIR /app

# Step 11: Create Profile Directory with write permissions
RUN mkdir -p profile/data && chmod -R 777 profile

# Important runtime instructions
# Note 1: For multi-worker tests, the container must be run with elevated sysctl privileges:
# --sysctl fs.inotify.max_user_watches=524288 --sysctl fs.inotify.max_user_instances=512
#
# Note 2: To use Docker, kind, or minikube inside the container, the host's Docker socket must be mounted:
# -v /var/run/docker.sock:/var/run/docker.sock

# Set the final command to launch a bash shell, putting the user in an interactive environment
# with the Python virtual environment activated and ready to use.
CMD ["/bin/bash"]