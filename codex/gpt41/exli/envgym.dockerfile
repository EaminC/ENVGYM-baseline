FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# System utilities and developer tools
RUN apt-get update && \
    apt-get install -y software-properties-common \
    build-essential \
    curl wget unzip zip gcc mono-mcs sudo emacs vim less git pkg-config libicu-dev firefox && \
    rm -rf /var/lib/apt/lists/*

# Set bash as default shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Create non-root user
RUN useradd -ms /bin/bash -c "ExLi User" exli && \
    echo "exli:exli" | chpasswd && adduser exli sudo
USER exli
ENV USER exli
WORKDIR /home/exli

# Install Miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Install SDKMAN and Java 8
RUN curl -s "https://get.sdkman.io" | bash
ENV PATH="$HOME/.sdkman/bin:${PATH}"
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 8.0.302-open"

# Copy repo in
COPY . /home/exli
WORKDIR /home/exli

# (Optional) Setup Conda for bash and install Python dependencies
RUN conda init bash

# Install Python requirements (editable, with dev/research extras)
RUN cd /home/exli/python && bash prepare-conda-env.sh 3.9 exli || true

# Install Java
RUN cd /home/exli/java && bash install.sh || true

# Install jacoco-extension and additional tools if needed
# RUN cd /home/exli/jacoco-extension && mvn clean install || true

# Expose /bin/bash CLI at repo root
WORKDIR /home/exli
ENTRYPOINT ["/bin/bash"]
