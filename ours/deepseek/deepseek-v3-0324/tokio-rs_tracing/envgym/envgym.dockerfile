FROM debian:stable-slim

WORKDIR /home/cc/EnvGym

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    libsystemd-dev \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -c "import urllib.request; urllib.request.urlopen('https://pypi.org')" || (echo "Network connectivity check failed" && exit 1)

RUN python3 -m pip install --upgrade pip --no-cache-dir --default-timeout=100 --verbose 2>&1 | tee pip-upgrade.log && \
    python3 -m pip install --upgrade setuptools wheel --no-cache-dir --default-timeout=100 --verbose 2>&1 | tee setuptools-install.log || \
    (echo "Pip installation failed, check pip-upgrade.log and setuptools-install.log" && exit 1)

COPY . .

RUN python3 -m pip install --no-cache-dir --verbose -r requirements.txt --default-timeout=100 2>&1 | tee requirements-install.log || \
    (echo "Requirements installation failed, check requirements-install.log" && exit 1)

RUN mkdir -p build && \
    cd build && \
    (cmake .. 2>&1 | tee cmake.log) && \
    (make 2>&1 | tee make.log) && \
    (make install 2>&1 | tee make-install.log) || \
    (echo "Build failed, check cmake.log, make.log, and make-install.log" && exit 1)

WORKDIR /home/cc/EnvGym

CMD ["/bin/bash"]