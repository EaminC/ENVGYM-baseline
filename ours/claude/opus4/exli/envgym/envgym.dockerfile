FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:${PATH}"

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/cc/EnvGym/data/exli

# Copy project files
COPY . /home/cc/EnvGym/data/exli/

# Install Python and pip if needed
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Install any Python dependencies if requirements.txt exists
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# Install any system dependencies from apt if apt-requirements.txt exists
RUN if [ -f apt-requirements.txt ]; then \
    apt-get update && \
    xargs -a apt-requirements.txt apt-get install -y && \
    rm -rf /var/lib/apt/lists/*; \
    fi

# Set up any necessary permissions
RUN chmod -R 755 /home/cc/EnvGym/data/exli

# Default command
CMD ["/bin/bash"]