# Build: docker build -f envgym.dockerfile -t exli-envgym .
# Run: docker run -it --rm exli-envgym

FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    apt-get update && \
    apt-get -qq -y install apt-utils curl wget unzip zip gcc mono-mcs sudo emacs vim less git build-essential pkg-config libicu-dev firefox && \
    curl -L https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz | tar xz -C /usr/local/bin

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Create working directory and copy repository
WORKDIR /workspace
COPY . /workspace/

# Download and install SDKMAN
RUN curl -s "https://get.sdkman.io" | bash
ENV PATH="/root/.sdkman/bin:${PATH}"

# Install Java 8 and Maven
RUN bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk install java 8.0.302-open && sdk install maven 3.8.3"

# Setup Python environment
RUN conda init bash && \
    eval "$(conda shell.bash hook)" && \
    conda create --name exli python=3.9 pip -y && \
    conda activate exli && \
    pip install --upgrade pip && \
    cd /workspace/python && \
    pip install -e .[dev,research]

# Install Java components
RUN bash -c "source /root/.sdkman/bin/sdkman-init.sh && sdk use java 8.0.302-open && sdk use maven 3.8.3 && cd /workspace/java/raninline && mvn install"

# Setup bash environment
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate exli" >> ~/.bashrc && \
    echo "[[ -s '/root/.sdkman/bin/sdkman-init.sh' ]] && source '/root/.sdkman/bin/sdkman-init.sh'" >> ~/.bashrc

# Set working directory to repository root
WORKDIR /workspace

# Start bash shell
CMD ["/bin/bash"]