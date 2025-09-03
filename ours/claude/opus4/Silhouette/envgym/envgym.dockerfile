FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    linux-headers-generic \
    software-properties-common \
    lsb-release \
    gnupg \
    cmake \
    memcached \
    openssh-client \
    tmux \
    netcat \
    procps \
    qemu-system-x86 \
    qemu-utils \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    cpu-checker \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main" && \
    apt-get update && apt-get install -y \
    llvm-15 \
    llvm-15-dev \
    llvm-15-tools \
    clang-15 \
    libclang-15-dev \
    clang-tools-15 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100 && \
    update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-15 100 && \
    update-alternatives --install /usr/bin/opt opt /usr/bin/opt-15 100

RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar xzf Python-3.10.13.tgz && \
    cd Python-3.10.13 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-3.10.13*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 100 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3.10 100

RUN pip3 install --upgrade pip && \
    pip3 install \
    pymemcache \
    python-memcached \
    psutil \
    pytz \
    qemu.qmp \
    intervaltree \
    aenum \
    netifaces \
    prettytable \
    tqdm \
    numpy \
    matplotlib

RUN mkdir -p /home/cc/EnvGym/data/Silhouette
WORKDIR /home/cc/EnvGym/data/Silhouette

RUN git clone https://github.com/iaoing/Silhouette.git silhouette_ae
WORKDIR /home/cc/EnvGym/data/Silhouette/silhouette_ae

RUN mkdir -p qemu_imgs && \
    mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh

RUN mkdir -p codebase/tools/disk_content && \
    echo -e "xx.*\nDumpDiskContent" > codebase/tools/disk_content/.gitignore

RUN mkdir -p codebase/tools/md5 && \
    echo -e "*.slo\n*.lo\n*.o\n*.obj\n*.gch\n*.pch\n*.so\n*.dylib\n*.dll\n*.mod\n*.lai\n*.la\n*.a\n*.lib\n*.exe\n*.out\n*.app" > codebase/tools/md5/.gitignore

RUN cd codebase/tools/md5 && \
    for i in 1 2 3 4 5; do \
        curl -fsSL -o md5.h https://raw.githubusercontent.com/JieweiWei/md5/master/md5.h && \
        curl -fsSL -o md5.cpp https://raw.githubusercontent.com/JieweiWei/md5/master/md5.cpp && \
        break || sleep 2; \
    done

RUN mkdir -p codebase/tools/src_info && \
    echo -e "DumpSrcAnnot\nxx.*" > codebase/tools/src_info/.gitignore

RUN mkdir -p codebase/tools/struct_layout_ast && \
    echo "DumpStructInfo" > codebase/tools/struct_layout_ast/.gitignore

RUN mkdir -p codebase/tools/struct_layout_pass && \
    mkdir -p codebase/trace/build-llvm15 && \
    mkdir -p codebase/trace/test/tracing_annot && \
    echo "test_traceing_annot" > codebase/trace/test/tracing_annot/.gitignore

RUN mkdir -p codebase/workload/ace/ace && \
    echo -e "__pycache__*\n*.log" > codebase/workload/ace/ace/.gitignore

RUN mkdir -p codebase/scripts/fs_conf/sshkey && \
    touch codebase/scripts/fs_conf/sshkey/fast25_ae_vm && \
    touch codebase/scripts/fs_conf/sshkey/fast25_ae_vm.pub && \
    chmod 600 codebase/scripts/fs_conf/sshkey/fast25_ae_vm && \
    chmod 644 codebase/scripts/fs_conf/sshkey/fast25_ae_vm.pub

RUN for i in {1..14}; do \
        mkdir -p evaluation/bugs/bug$i/result; \
    done

RUN mkdir -p evaluation/bugs/bug1/result/result_validation/cannot_write && \
    mkdir -p evaluation/bugs/bug2/result/result_validation/mismatch_both_oracle && \
    mkdir -p evaluation/bugs/bug3/result/result_validation/mismatch_old_value && \
    mkdir -p evaluation/bugs/bug3/result/result_details && \
    mkdir -p evaluation/bugs/bug4/result/result_validation/mismatch_both_oracle && \
    mkdir -p evaluation/bugs/bug5/result/result_validation/semantic_bug_diff_dot_ino && \
    mkdir -p evaluation/bugs/bug6/result/result_validation/mismatch_both_oracle && \
    mkdir -p evaluation/bugs/bug7/result/result_validation/get_prev_oracle_remount_failed && \
    mkdir -p evaluation/bugs/bug8/result/result_tracing/syslog_error && \
    mkdir -p evaluation/bugs/bug9/result/result_validation/cannot_write && \
    mkdir -p evaluation/bugs/bug10/result/result_tracing/unknown_stat_error && \
    mkdir -p evaluation/bugs/bug11/result/result_validation/get_post_oracle_remount_failed && \
    mkdir -p evaluation/bugs/bug12/result/result_validation/semantic_bug_file_size_after_append && \
    mkdir -p evaluation/bugs/bug13/result/result_validation/mismatch_both_oracle && \
    mkdir -p evaluation/bugs/bug14/result/result_validation/mismatch_old_value

RUN git config --global http.postBuffer 524288000 && \
    git config --global http.timeout 600 && \
    git config --global core.compression 0

RUN mkdir -p thirdPart && \
    cd thirdPart && \
    for i in 1 2 3 4 5; do \
        git clone --depth 1 https://github.com/NVSL/linux-nova.git nova-chipmunk-disable-chipmunk-bugs && \
        break || sleep 5; \
    done && \
    mkdir -p pmfs-chipmunk-disable-chipmunk-bugs

RUN cd thirdPart && \
    for i in 1 2 3; do \
        git clone --depth 1 https://github.com/cosmoss-jigu/witcher.git && \
        git clone --depth 1 https://github.com/liuml07/giri.git && \
        git clone --depth 1 https://github.com/utsaslab/chipmunk.git && \
        git clone --depth 1 https://github.com/KIT-OSGroup/vinter.git && \
        git clone --depth 1 https://github.com/utsaslab/crashmonkey.git && \
        git clone --depth 1 https://github.com/NVSL/PMFS-new.git && \
        git clone --depth 1 https://github.com/utsaslab/WineFS.git && \
        break || sleep 5; \
    done

RUN mkdir -p evaluation/scalability/seq1 && \
    mkdir -p evaluation/scalability/seq2 && \
    mkdir -p evaluation/scalability/seq3

RUN service memcached start

RUN echo '#!/bin/bash\nservice memcached start\nexec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /home/cc/EnvGym/data/Silhouette/silhouette_ae

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]