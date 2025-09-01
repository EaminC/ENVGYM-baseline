FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    python3-pip \
    libboost-all-dev \
    libeigen3-dev \
    libgmp-dev \
    libmpfr-dev \
    tcl-dev \
    tk-dev \
    libreadline-dev \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN if [ -f "requirements.txt" ]; then \
        echo "requirements.txt found. Content:"; \
        cat requirements.txt; \
        echo "Installing with verbose output..."; \
        pip3 install --no-cache-dir -v -r requirements.txt; \
    else \
        echo "requirements.txt not found. Skipping pip install."; \
    fi

RUN mkdir build && \
    cd build && \
    cmake .. | tee cmake.log && \
    make -j$(nproc) | tee make.log || { cat cmake.log make.log; exit 1; }

ENV PATH="/app/bin:${PATH}"
WORKDIR /app

CMD ["/bin/bash"]