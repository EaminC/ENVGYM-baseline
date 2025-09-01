# Dockerfile for creating an environment gym for the current repository
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install software and utilities
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    apt-get update && \
    apt-get -qq -y install apt-utils curl wget unzip zip gcc mono-mcs sudo emacs vim less git build-essential pkg-config libicu-dev firefox

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Add new user
RUN useradd -ms /bin/bash -c "ExLi User" envgym && echo "envgym:envgym" | chpasswd && adduser envgym sudo
USER envgym
ENV USER envgym
WORKDIR /home/envgym/

# Install SDKMAN and Java
RUN curl -s "https://get.sdkman.io" | bash
ENV PATH="$HOME/.sdkman/bin:${PATH}"
RUN bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install java 8.0.302-open"

# Initialize conda
RUN conda init bash && source ~/.bashrc

# Copy the entire repository
COPY --chown=envgym:envgym . /home/envgym/exli/

# Set working directory to the repository root
WORKDIR /home/envgym/exli

# Prepare conda environment
RUN cd python && bash prepare-conda-env.sh

# Install InlineTest
RUN cd ../inlinetest/java && bash install.sh

# Install ExLi
RUN cd ../exli/java && bash install.sh

# Entrypoint to bash at the repository root
ENTRYPOINT ["/bin/bash"]