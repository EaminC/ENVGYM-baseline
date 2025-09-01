FROM python:3.7-slim-buster

WORKDIR /app

# Install system dependencies with network fixes
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    openjdk-8-jdk \
    bc \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install Python 2.7 from backports
RUN echo "deb http://archive.debian.org/debian/ stretch main" > /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    python2.7 \
    python2.7-dev \
    python-pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install virtualenv
RUN python3.7 -m pip install --upgrade pip && \
    python2.7 -m pip install --upgrade pip virtualenv

# Install Python 2.7 dependencies
RUN python2.7 -m pip install \
    pystan \
    tensorflow==1.5.0 \
    antlr4-python2-runtime==4.7.1 && \
    python2.7 -m pip install pyro-ppl==0.2.1 \
    -f https://download.pytorch.org/whl/cpu/torch_stable.html

COPY . .

# Install requirements for both Python versions
RUN python3.7 -m pip install -r requirements.txt && \
    python2.7 -m pip install -r requirements.txt

# Setup environment
ENV CLASSPATH=/app/antlr-4.7.1-complete.jar:$CLASSPATH
RUN mkdir -p /app/generated && \
    mkdir -p /app/temp && \
    mkdir -p /app/logs

# Verify CPU-only environment
RUN python3 -c "import tensorflow as tf; assert not tf.test.is_gpu_available()" && \
    python2 -c "import tensorflow as tf; assert not tf.test.is_gpu_available()"

WORKDIR /app

CMD ["/bin/bash"]