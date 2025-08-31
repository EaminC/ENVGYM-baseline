# Base: modern Debian for full dev tool support
FROM debian:bookworm-slim

# Install essentials: git, curl, build tools, Rust toolchain
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        pkg-config \
        libssl-dev \
        bash \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via official installer
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# Create a working folder and copy repo
WORKDIR /nushell_nushell
COPY . /nushell_nushell

# Install the repo and all plugins using included script
RUN bash scripts/install-all.sh

# Set default shell and working directory
WORKDIR /nushell_nushell
ENTRYPOINT ["/bin/bash"]
