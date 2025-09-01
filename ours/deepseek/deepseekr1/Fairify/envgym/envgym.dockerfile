FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies with PPA
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y git python3.7 python3.7-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory
RUN mkdir -p /home/cc/EnvGym/data/Fairify
WORKDIR /home/cc/EnvGym/data/Fairify

# Clone repository
RUN git clone https://github.com/sumonbis/Fairify .

# Modify requirements.txt for CPU
RUN sed -i 's/tensorflow==2.5.0/tensorflow-cpu==2.5.0/' requirements.txt

# Verify output directories exist
RUN ls \
    src/AC/res-race/readme.md \
    src/AC/res-sex/readme.md \
    src/BM/res/readme.md \
    src/GC/res-sex/readme.md \
    stress/AC/res/readme.md \
    stress/BM/res/readme.md \
    stress/GC/res/readme.md \
    targeted/AC/res/readme.md \
    targeted/BM/res/readme.md \
    targeted/GC/res/readme.md \
    targeted2/AC/res/readme.md \
    targeted2/BM/res/readme.md \
    targeted2/GC/res/readme.md \
    relaxed/AC/res/readme.md \
    relaxed/BM/res/readme.md \
    relaxed/GC/res/readme.md

# Set execute permissions
RUN chmod +x \
    src/fairify.sh \
    stress/fairify-stress.sh \
    relaxed/fairify-relaxed.sh \
    targeted/fairify-targeted.sh \
    targeted2/fairify-targeted.sh

# Create and activate virtual environment
RUN python3.7 -m venv fenv
ENV VIRTUAL_ENV=/home/cc/EnvGym/data/Fairify/fenv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Verify package installations
RUN python -c "import tensorflow as tf; print(tf.__version__)" && \
    python -c "import z3" && \
    python -c "import aif360"

# Verify dataset integrity
RUN ls data/adult/adult.* && \
    ls data/bank/bank-additional-* && \
    ls data/german/german.*

# Verify output documentation references CSV
RUN grep -r "csv" \
    src/AC/res-race/readme.md \
    src/AC/res-sex/readme.md \
    src/BM/res/readme.md \
    src/GC/res-sex/readme.md \
    stress/AC/res/readme.md \
    stress/BM/res/readme.md \
    stress/GC/res/readme.md \
    targeted/AC/res/readme.md \
    targeted/BM/res/readme.md \
    targeted/GC/res/readme.md \
    targeted2/AC/res/readme.md \
    targeted2/BM/res/readme.md \
    targeted2/GC/res/readme.md \
    relaxed/AC/res/readme.md \
    relaxed/BM/res/readme.md \
    relaxed/GC/res/readme.md

# Dry-run verifications
RUN cd src && ./fairify.sh GC --dry-run && cd .. && \
    cd src && ./fairify.sh adult --dry-run && cd .. && \
    cd src && ./fairify.sh bank --dry-run && cd .. && \
    cd targeted && ./fairify-targeted.sh AC --dry-run && cd .. && \
    cd targeted && ./fairify-targeted.sh BM --dry-run && cd .. && \
    cd targeted && ./fairify-targeted.sh GC --dry-run && cd .. && \
    cd targeted2 && ./fairify-targeted.sh AC --dry-run && cd .. && \
    cd targeted2 && ./fairify-targeted.sh BM --dry-run && cd .. && \
    cd targeted2 && ./fairify-targeted.sh GC --dry-run && cd ..

# Set default command
CMD ["/bin/bash"]