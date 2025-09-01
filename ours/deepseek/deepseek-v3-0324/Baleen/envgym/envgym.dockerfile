FROM debian:bullseye-slim

# Set base directory
ENV BASE_DIR /home/cc/EnvGym/data/Baleen
WORKDIR $BASE_DIR

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    bzip2 \
    ca-certificates \
    python3.9 \
    python3-pip \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install micromamba with verified URL and improved error handling
RUN mkdir -p /opt/micromamba && \
    chmod 755 /opt/micromamba && \
    wget -qO /tmp/micromamba.tar.bz2 "https://micro.mamba.pm/api/micromamba/linux-64/latest" && \
    tar -xjf /tmp/micromamba.tar.bz2 -C /opt/micromamba --strip-components=1 bin/micromamba && \
    rm -f /tmp/micromamba.tar.bz2 && \
    /opt/micromamba/micromamba --help || echo "Micromamba verification failed"

# Clone repository with submodules
RUN git clone --recurse-submodules https://github.com/wonglkd/Baleen-FAST24.git && \
    cd Baleen-FAST24 && \
    git submodule update --init --recursive

# Set up environment using pip
WORKDIR $BASE_DIR/Baleen-FAST24
RUN pip install -r BCacheSim/install/requirements.txt && \
    pip install jupyter

# Download trace files
WORKDIR $BASE_DIR/Baleen-FAST24/data
RUN chmod +x get-tectonic.sh && \
    ./get-tectonic.sh && \
    chmod +x clean.sh

# Setup reproduce script and make executable
WORKDIR $BASE_DIR/Baleen-FAST24/notebooks/reproduce
RUN chmod +x reproduce_commands.sh

# Create getting-started script
WORKDIR $BASE_DIR/Baleen-FAST24
RUN echo '#!/bin/bash\n\
cd /home/cc/EnvGym/data/Baleen/Baleen-FAST24\n\
./BCacheSim/run_py.sh py -B -m BCacheSim.cachesim.simulate_ap --config runs/example/rejectx/config.json' > getting-started.sh && \
    chmod +x getting-started.sh

# Set default command
WORKDIR $BASE_DIR/Baleen-FAST24
CMD ["/bin/bash"]