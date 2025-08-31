FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install basic python dependencies
RUN pip install --no-cache-dir numpy torch torchvision

# Copy all repository files into /app
WORKDIR /app
COPY . /app

# Start with bash terminal
CMD ["/bin/bash"]
