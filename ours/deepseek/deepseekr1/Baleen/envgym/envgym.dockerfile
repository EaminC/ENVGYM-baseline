FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libnuma-dev \
    python3 \
    python3-pip \
    python3-dev \
    wget \
    libaio-dev \
    libboost-all-dev \
    libtbb-dev \
    libgflags-dev \
    libssl-dev \
    zlib1g-dev
RUN mkdir -p /home/cc/EnvGym/data/Baleen
WORKDIR /home/cc/EnvGym/data/Baleen
RUN git clone --recurse-submodules https://github.com/wonglkd/Baleen-FAST24.git
WORKDIR /home/cc/EnvGym/data/Baleen/Baleen-FAST24
RUN if [ -f requirements.txt ]; then pip3 install -r requirements.txt; else echo "requirements.txt not found. Skipping."; fi
WORKDIR /home/cc/EnvGym/data/Baleen/Baleen-FAST24/BCacheSim
RUN mkdir build
WORKDIR build
RUN cmake .. 2>&1 | tee cmake_output.log || (echo "===== CMake Output ====="; cat cmake_output.log; if [ -f CMakeFiles/CMakeError.log ]; then echo "===== Error Log ====="; cat CMakeFiles/CMakeError.log; fi; exit 1)
RUN make 2>&1 | tee make_output.log || (echo "===== Make Output ====="; cat make_output.log; exit 1)
WORKDIR /home/cc/EnvGym/data/Baleen/Baleen-FAST24
RUN bash data/get-tectonic.sh
ENV BCACHESIM_HOME="/home/cc/EnvGym/data/Baleen/Baleen-FAST24/BCacheSim"
WORKDIR /home/cc/EnvGym/data/Baleen/Baleen-FAST24
CMD ["/bin/bash"]