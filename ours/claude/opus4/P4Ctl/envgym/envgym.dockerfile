FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

RUN apt-get update && apt-get install -y \
    python3.7 python3.7-dev python3.7-venv python3-pip \
    build-essential git cmake make gcc g++ \
    libfl-dev bpfcc-tools linux-headers-generic \
    libbpfcc-dev python3-bpfcc ncat iproute2 iputils-ping \
    wget curl sudo vim nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

WORKDIR /home/cc/EnvGym/data/P4Ctl

RUN wget https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.gz && \
    tar -xzf bison-3.8.2.tar.gz && \
    cd bison-3.8.2 && \
    ./configure --prefix=/home/cc/EnvGym/data/P4Ctl/tools && \
    make && make install && \
    cd .. && rm -rf bison-3.8.2 bison-3.8.2.tar.gz

RUN wget https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz && \
    tar -xzf flex-2.6.4.tar.gz && \
    cd flex-2.6.4 && \
    ./configure --prefix=/home/cc/EnvGym/data/P4Ctl/tools && \
    make && make install && \
    cd .. && rm -rf flex-2.6.4 flex-2.6.4.tar.gz

ENV PATH=/home/cc/EnvGym/data/P4Ctl/tools/bin:$PATH

RUN python3.7 -m venv p4control-env

RUN . p4control-env/bin/activate && \
    pip install --upgrade pip && \
    pip install scapy==2.4.5

RUN mkdir -p /home/cc/EnvGym/data/P4Ctl/bf-sde-9.7.0/install

ENV SDE=/home/cc/EnvGym/data/P4Ctl/bf-sde-9.7.0/
ENV SDE_INSTALL=/home/cc/EnvGym/data/P4Ctl/bf-sde-9.7.0/install
ENV P4CTL_HOME=/home/cc/EnvGym/data/P4Ctl

RUN echo 'export SDE=/home/cc/EnvGym/data/P4Ctl/bf-sde-9.7.0/' >> ~/.bashrc && \
    echo 'export SDE_INSTALL=/home/cc/EnvGym/data/P4Ctl/bf-sde-9.7.0/install' >> ~/.bashrc && \
    echo 'export P4CTL_HOME=/home/cc/EnvGym/data/P4Ctl' >> ~/.bashrc && \
    echo 'export PATH=/home/cc/EnvGym/data/P4Ctl/tools/bin:$PATH' >> ~/.bashrc && \
    echo 'source /home/cc/EnvGym/data/P4Ctl/p4control-env/bin/activate' >> ~/.bashrc

COPY . /home/cc/EnvGym/data/P4Ctl/P4Control

WORKDIR /home/cc/EnvGym/data/P4Ctl/P4Control

RUN cd compiler && \
    export PATH=/home/cc/EnvGym/data/P4Ctl/tools/bin:$PATH && \
    make clean && \
    make netcl && \
    cd ..

RUN echo "version: '3.8'" > docker-compose.yml && \
    echo "services:" >> docker-compose.yml && \
    echo "  host1:" >> docker-compose.yml && \
    echo "    build: ." >> docker-compose.yml && \
    echo "    container_name: p4ctl_host1" >> docker-compose.yml && \
    echo "    networks:" >> docker-compose.yml && \
    echo "      p4net:" >> docker-compose.yml && \
    echo "        ipv4_address: 10.0.0.1" >> docker-compose.yml && \
    echo "    privileged: true" >> docker-compose.yml && \
    echo "  host2:" >> docker-compose.yml && \
    echo "    build: ." >> docker-compose.yml && \
    echo "    container_name: p4ctl_host2" >> docker-compose.yml && \
    echo "    networks:" >> docker-compose.yml && \
    echo "      p4net:" >> docker-compose.yml && \
    echo "        ipv4_address: 10.0.0.2" >> docker-compose.yml && \
    echo "    privileged: true" >> docker-compose.yml && \
    echo "  host3:" >> docker-compose.yml && \
    echo "    build: ." >> docker-compose.yml && \
    echo "    container_name: p4ctl_host3" >> docker-compose.yml && \
    echo "    networks:" >> docker-compose.yml && \
    echo "      p4net:" >> docker-compose.yml && \
    echo "        ipv4_address: 10.0.0.3" >> docker-compose.yml && \
    echo "    privileged: true" >> docker-compose.yml && \
    echo "networks:" >> docker-compose.yml && \
    echo "  p4net:" >> docker-compose.yml && \
    echo "    driver: bridge" >> docker-compose.yml && \
    echo "    ipam:" >> docker-compose.yml && \
    echo "      config:" >> docker-compose.yml && \
    echo "        - subnet: 10.0.0.0/24" >> docker-compose.yml

RUN echo "# Sample NetCL rules file" > netcl_rules.ncl && \
    echo "allow host1 -> host2 : tcp/80" >> netcl_rules.ncl && \
    echo "deny host1 -> host3 : *" >> netcl_rules.ncl

RUN touch compiled_rules.out

WORKDIR /home/cc/EnvGym/data/P4Ctl/P4Control

CMD ["/bin/bash"]