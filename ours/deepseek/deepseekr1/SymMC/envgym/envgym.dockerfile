FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-8-jdk \
        ant \
        g++ \
        make \
        zlib1g-dev \
        cmake \
        libgmp-dev \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* && \
    java -version && \
    ant -version && \
    g++ --version && \
    make --version && \
    cmake --version && \
    git --version

RUN mkdir -p /home/cc/EnvGym/data/SymMC
COPY . /home/cc/EnvGym/data/SymMC

WORKDIR /home/cc/EnvGym/data/SymMC

RUN chmod +x Enhanced_Kodkod/*.sh
RUN chmod +x Enumerator_Estimator/*.sh

WORKDIR /home/cc/EnvGym/data/SymMC/Enhanced_Kodkod
RUN java -XshowSettings:properties -version
RUN test -f "lib/org.alloytools.alloy.dist.jar" || { echo "Required jar missing: org.alloytools.alloy.dist.jar"; exit 1; }
RUN ls -lR lib
RUN ant -verbose clean
RUN ant -Djavac.fork=true -Djavac.executable=javac -verbose compile
RUN ls -l bin | grep '.class'

WORKDIR /home/cc/EnvGym/data/SymMC/Enumerator_Estimator
ENV MAKEFLAGS="-j$(nproc)"
RUN ./build.sh

WORKDIR /home/cc/EnvGym/data/SymMC
CMD ["/bin/bash"]