# envgym.dockerfile for sixthsense
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /sixthsense

# Install system and Python dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy all repo contents
COPY . /sixthsense

# (Optional) Create plots/models/results folders
RUN mkdir -p plots models results

# Install Python requirements
RUN python3 -m pip install --upgrade pip \
    && pip3 install -r requirements.txt

# Default shell entry
CMD ["/bin/bash"]
