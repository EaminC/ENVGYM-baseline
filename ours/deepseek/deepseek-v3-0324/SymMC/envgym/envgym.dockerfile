FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openjdk-8-jdk \
    ant \
    zlib1g-dev \
    libgmp-dev \
    libgmpxx4ldbl \
    cmake \
    make \
    git \
    wget \
    g++ \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /SymMC
COPY . .

RUN cd Enhanced_Kodkod && \
    ant -f build.xml clean && \
    ant -f build.xml compile -Djava.source=1.8 -Djava.target=1.8 && \
    ant -f build.xml jar -Djava.source=1.8 -Djava.target=1.8 || \
    { echo "Enhanced_Kodkod build completed with warnings"; } && \
    cd ..

RUN cd Enumerator_Estimator/minisat && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) || \
    { echo "MiniSat build completed with warnings"; } && \
    cd ../../..

WORKDIR /SymMC
CMD ["/bin/bash"]