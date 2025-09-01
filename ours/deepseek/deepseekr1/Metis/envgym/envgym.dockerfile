FROM ubuntu:20.04
WORKDIR /home/cc/EnvGym/data

# Install base dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git build-essential mtd-utils xfsprogs python3-pip rename spin \
    libssl-dev libxxhash-dev zlib1g-dev libgoogle-perftools-dev libfuse-dev gcc cmake bc \
    linux-headers-generic && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip3 install numpy scipy matplotlib pulp

# Clone repositories with robust retry mechanism
RUN for repo in Metis RefFS IOCov fsl-spin swarm-mcfs; do \
    for i in {1..5}; do \
        git clone https://github.com/sbu-fsl/${repo}.git && break || \
        (echo "Retry $i/5 for $repo" && rm -rf ${repo} && sleep 15); \
    done; \
done

# Clone explode with extended retries and validation
RUN for i in {1..5}; do \
    git clone https://github.com/sbu-fsl/explode-0.1pre.git && \
    [ -d "explode-0.1pre" ] && break || \
    (echo "Retry $i/5 for explode" && rm -rf explode-0.1pre && sleep 15); \
done; \
[ ! -d "explode-0.1pre" ] && echo "Failed to clone explode" && exit 1 || true

# Build Metis components
RUN cd Metis/scripts && ./setup-deps.sh
RUN cd Metis && make -j$(nproc) && make install
RUN cd Metis/example && make -j$(nproc)
RUN cd Metis/promela-demo && make -j$(nproc)

# Build RefFS and explode
RUN cd RefFS && ./setup_verifs2.sh
RUN cd explode-0.1pre && make -j$(nproc)

# Cleanup
RUN rm -rf Metis/.git RefFS/.git IOCov/.git fsl-spin/.git swarm-mcfs/.git explode-0.1pre/.git && \
    apt-get clean && rm -rf /tmp/* /var/tmp/*

# Dynamic kernel module loading entrypoint
RUN echo -e '#!/bin/bash\n\
base_dir="/home/cc/EnvGym/data/Metis/kernel"\n\
KERNEL_MAJOR=$(uname -r | cut -d. -f1)\n\
KERNEL_MINOR=$(uname -r | cut -d. -f2)\n\
if [ $KERNEL_MAJOR -lt 4 ] || { [ $KERNEL_MAJOR -eq 4 ] && [ $KERNEL_MINOR -lt 15 ]; }; then\n\
    BRD_DIR="brd-for-4.4"\n\
elif [ $KERNEL_MAJOR -lt 5 ] || { [ $KERNEL_MAJOR -eq 5 ] && [ $KERNEL_MINOR -lt 4 ]; }; then\n\
    BRD_DIR="brd-for-4.15"\n\
elif [ $KERNEL_MAJOR -lt 5 ] || { [ $KERNEL_MAJOR -eq 5 ] && [ $KERNEL_MINOR -lt 15 ]; }; then\n\
    BRD_DIR="brd-for-5.4.0"\n\
else\n\
    BRD_DIR="brd-for-5.15.0"\n\
fi\n\
make -s -j$(nproc) -C /lib/modules/$(uname -r)/build M=$base_dir/$BRD_DIR >/dev/null 2>&1\n\
modprobe brd rd_nr=1 rd_size=1048576 || insmod $base_dir/$BRD_DIR/brd.ko rd_nr=1 rd_size=1048576\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /home/cc/EnvGym/data/Metis
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]