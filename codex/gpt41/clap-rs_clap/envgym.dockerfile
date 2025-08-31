FROM rust:1.74-slim

# Install system dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 python3-pip \
    nodejs npm \
    git make \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pre-commit (for repo QA/test tools)
RUN pip3 install pre-commit

# Create a user for safer CLI usage (optional)
RUN useradd -m envuser
WORKDIR /home/envuser

# Copy repo files
COPY . /home/envuser/clap-rs_clap
WORKDIR /home/envuser/clap-rs_clap

# Set up Rust toolchain
RUN rustup install stable && rustup default stable

# Set PATH (in case)
ENV PATH="$PATH:/home/envuser/.cargo/bin"

# For Rust build cache and correct permissions
RUN chown -R envuser:envuser /home/envuser
USER envuser

# Build the clap workspace for development
RUN cargo build --workspace

# Entrypoint in repo root
ENTRYPOINT ["/bin/bash"]
