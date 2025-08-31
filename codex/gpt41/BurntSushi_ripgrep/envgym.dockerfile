FROM rust:1.88-slim

# Install build essentials
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create user for safety (optional, but usually recommended)
ARG USER=envgym
RUN useradd -m $USER

# Copy repo files and set root
WORKDIR /repo
COPY . /repo

# Install ripgrep
RUN cargo install --path .

# Set up environment and entrypoint
USER $USER
ENV PATH="/home/$USER/.cargo/bin:${PATH}" 
ENTRYPOINT ["/bin/bash"]
