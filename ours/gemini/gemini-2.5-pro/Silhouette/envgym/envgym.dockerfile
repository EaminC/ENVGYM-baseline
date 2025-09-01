# Use Ubuntu 20.04 as the base image, as specified in the plan.
FROM ubuntu:20.04

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variable for LLVM 15 home, which is required by various build scripts.
ENV LLVM15_HOME=/usr/lib/llvm-15

# Define the base directory for the project to match the plan's structure.
ENV PROJ_BASE_DIR=/home/cc/EnvGym/data

# Step 1: System update and install core utilities for adding repositories.
# This is split from the main installation to improve caching and debuggability.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    gnupg \
    curl \
    git \
    ca-certificates

# Step 2: Add PPA for Python 3.10 and the LLVM repository.
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    mkdir -p /etc/apt/keyrings && \
    wget -qO /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key && \
    gpg --dearmor -o /etc/apt/keyrings/llvm-archive-keyring.gpg /tmp/llvm-snapshot.gpg.key && \
    rm /tmp/llvm-snapshot.gpg.key && \
    echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" > /etc/apt/sources.list.d/llvm.list

# Step 3 & 4: Update package lists again and install all required software packages.
# Prevent services like memcached from starting during build.
RUN echo 'exit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    llvm-15-dev \
    clang-15 \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    patch \
    qemu-system-x86 \
    memcached \
    truncate \
    sshpass && \
    # NOTE: The kernel header version is hardcoded. This is a deliberate choice
    # based on the assumption that it matches the kernel version inside the guest VM image.
    # A mismatch may cause kernel module compilation to succeed but fail at runtime.
    wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-5.4.0-150_5.4.0-150.167_all.deb && \
    wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-5.4.0-150-generic_5.4.0-150.167_amd64.deb && \
    dpkg -i linux-headers-5.4.0-150_5.4.0-150.167_all.deb linux-headers-5.4.0-150-generic_5.4.0-150.167_amd64.deb && \
    rm linux-headers-5.4.0-150_5.4.0-150.167_all.deb linux-headers-5.4.0-150-generic_5.4.0-150.167_amd64.deb && \
    rm /usr/sbin/policy-rc.d && \
    # Install pip for the correct Python version.
    curl https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    # Clean up apt cache to reduce image size.
    rm -rf /var/lib/apt/lists/*

# Set the working directory to the project's data directory.
WORKDIR ${PROJ_BASE_DIR}

# Clone the Silhouette repository and its submodules.
RUN git clone https://github.com/iaoing/Silhouette.git && \
    cd Silhouette && \
    git submodule update --init --recursive

# Set the working directory to the cloned repository's root.
WORKDIR ${PROJ_BASE_DIR}/Silhouette

# Set PYTHONPATH to allow project scripts to be imported from the root directory.
ENV PYTHONPATH=${PROJ_BASE_DIR}/Silhouette/codebase

# Install Python dependencies directly, isolating from the project's install script.
RUN python3.10 -m pip install matplotlib numpy pandas pymemcache paramiko scp psutil pytz qemu.qmp intervaltree aenum netifaces prettytable tqdm memcache

# Download the large guest VM image from Zenodo.
RUN mkdir -p ${PROJ_BASE_DIR}/qemu_imgs && \
    wget https://zenodo.org/records/14550794/files/silhouette_guest_vm.qcow2 -O ${PROJ_BASE_DIR}/qemu_imgs/silhouette_guest_vm.qcow2

# Step 5: Compile all custom tools, LLVM passes, kernel modules, and workloads with verification.
# Compile custom tools.
RUN cd codebase/tools && for d in */ ; do (cd "$d" && [ -f Makefile ] && make); done
# Verify custom tools compilation by checking existence and running with --help to test linking.
RUN test -x codebase/tools/disk_content/DumpDiskContent && \
    test -f codebase/tools/md5/md5.so && \
    test -x codebase/tools/src_info/DumpSrcInfo && \
    test -x codebase/tools/struct_layout_ast/DumpStructLayout && \
    test -f codebase/tools/struct_layout_pass/DumpStructLayout.so && \
    codebase/tools/disk_content/DumpDiskContent --help && \
    codebase/tools/src_info/DumpSrcInfo --help && \
    codebase/tools/struct_layout_ast/DumpStructLayout --help

# Compile LLVM passes.
RUN cd codebase/trace/build-llvm15 && make
# Verify LLVM passes compilation.
RUN test -f codebase/trace/build-llvm15/libnogiri.so && \
    test -f codebase/trace/build-llvm15/Si.so

# Compile NOVA kernel module.
RUN cd thirdPart/nova-chipmunk-disable-chipmunk-bugs && make
# Verify NOVA kernel module compilation.
RUN test -f thirdPart/nova-chipmunk-disable-chipmunk-bugs/nova.ko

# Compile PMFS kernel module.
RUN cd thirdPart/pmfs-chipmunk-disable-chipmunk-bugs && make
# Verify PMFS kernel module compilation.
RUN test -f thirdPart/pmfs-chipmunk-disable-chipmunk-bugs/pmfs.ko

# Compile WiNEFS kernel module.
RUN cd thirdPart/winefs-chipmunk-disable-chipmunk-bugs && make
# Verify WiNEFS kernel module compilation.
RUN test -f thirdPart/winefs-chipmunk-disable-chipmunk-bugs/winefs.ko

# Compile custom workloads.
RUN cd codebase/workload/custom_workload/base_ops && make
# Verify custom workloads compilation.
RUN test -x codebase/workload/custom_workload/base_ops/test_creat.exe && \
    test -x codebase/workload/custom_workload/base_ops/test_write.exe && \
    test -x codebase/workload/custom_workload/base_ops/test_read.exe

# As per the plan, modify configuration files and set permissions.
# This replaces the incompatible prepare.sh script.
RUN find codebase/scripts/fs_conf/ -type f -exec sed -i 's|/home/bing/projects/silhouette|/home/cc/EnvGym/data/Silhouette|g' {} + && \
    sed -i 's|/home/bing/projects/silhouette|/home/cc/EnvGym/data/Silhouette|g' codebase/scripts/vm_mgr/vm_instance.py && \
    chmod 600 codebase/scripts/fs_conf/sshkey/fast25_ae_vm

# Step 7: Create the NVDIMM backing file required for PMFS testing.
RUN truncate -s 64G ${PROJ_BASE_DIR}/pmem.img

# Set the final working directory to the repository root for user convenience.
WORKDIR ${PROJ_BASE_DIR}/Silhouette

# Start a bash shell when the container is run.
CMD ["/bin/bash"]