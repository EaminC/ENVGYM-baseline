FROM python:3.9-slim
WORKDIR /app
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    tree \
    cmake \
    libopenblas-dev \
    libopenmpi-dev \
    gfortran \
    libjpeg-dev \
    zlib1g-dev
COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip setuptools
RUN cat requirements.txt | grep -vE '^#|^$' | while read requirement; do \
    pip install --no-cache-dir -v "$requirement"; \
done
COPY . .
CMD ["/bin/bash"]