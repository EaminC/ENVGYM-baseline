FROM python:3.9-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Clone the TabPFN repository
RUN git clone https://github.com/PriorLabs/TabPFN.git .

# Install the package and its development dependencies
RUN pip install --no-cache-dir -e ".[dev]"

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]