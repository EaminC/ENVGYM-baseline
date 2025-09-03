FROM ubuntu:22.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/SymMC

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    cmake \
    git \
    gcc \
    g++ \
    python3 \
    python3-pip \
    build-essential \
    wget \
    ca-certificates \
    libz-dev \
    libgmp-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/minisat/minisat-releases-2.2.0 \
    && wget https://github.com/msoos/minisat/archive/refs/tags/releases/2.2.0.zip -O minisat.zip \
    && unzip minisat.zip -d /tmp/minisat \
    && cd /tmp/minisat/minisat-releases-2.2.0 \
    && sed -i 's/friend Lit mkLit(Var var, bool sign = false);/friend Lit mkLit(Var var, bool sign);/' core/SolverTypes.h \
    && echo "cmake_minimum_required(VERSION 3.10)" > CMakeLists.txt \
    && echo "project(minisat)" >> CMakeLists.txt \
    && echo "set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -Wno-literal-suffix\")" >> CMakeLists.txt \
    && echo "add_library(minisat STATIC" >> CMakeLists.txt \
    && echo "    core/Solver.cc" >> CMakeLists.txt \
    && echo "    core/SolverTypes.h" >> CMakeLists.txt \
    && echo "    mtl/Vec.h" >> CMakeLists.txt \
    && echo ")" >> CMakeLists.txt \
    && echo "target_include_directories(minisat PUBLIC \${CMAKE_CURRENT_SOURCE_DIR})" >> CMakeLists.txt \
    && echo "install(TARGETS minisat DESTINATION lib)" >> CMakeLists.txt \
    && echo "install(FILES core/Solver.h core/SolverTypes.h DESTINATION include/minisat)" >> CMakeLists.txt \
    && mkdir -p build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/minisat*

RUN wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.12-bin.tar.gz \
    && tar -xzf apache-ant-1.10.12-bin.tar.gz \
    && mv apache-ant-1.10.12 /opt/ant \
    && rm apache-ant-1.10.12-bin.tar.gz

ENV PATH="/opt/ant/bin:${PATH}"
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN useradd -m -s /bin/bash devuser
USER devuser
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/SymMC

COPY --chown=devuser:devuser . .

RUN cd Enhanced_Kodkod \
    && chmod +x build.sh \
    && bash -x ./build.sh 2>&1 | tee build.log \
    && cd ../Enumerator_Estimator \
    && chmod +x build.sh \
    && bash -x ./build.sh 2>&1 | tee build.log

USER root
WORKDIR /home/cc/EnvGym/data-gpt-4.1mini/SymMC

CMD ["/bin/bash"]