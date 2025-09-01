# Stage 1: Build stage for tools and dependencies
FROM rust:1.77-slim-bullseye AS builder

# Install all build dependencies in a single layer including perl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        dpkg \
        fakeroot \
        git \
        clang \
        cmake \
        pkg-config \
        libssl-dev \
        libc6-dev \
        build-essential \
        libdbus-1-dev \
        libsqlite3-dev \
        libgit2-dev \
        libssh2-1-dev \
        perl && \
    rm -rf /var/lib/apt/lists/*

# Install bat from GitHub release
RUN wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb && \
    dpkg -i bat_0.25.0_amd64.deb && \
    rm bat_0.25.0_amd64.deb

# Install bat-extras
RUN git clone https://github.com/eth-p/bat-extras.git /tmp/bat-extras && \
    cd /tmp/bat-extras && \
    ./build.sh --install && \
    cd / && \
    rm -rf /tmp/bat-extras

# Update Rust toolchain before installing tools
RUN rustup update stable

# Install Rust tools using cargo with verbose logging and separate commands
RUN cargo install --verbose cargo-audit
RUN cargo install --verbose cross

# Clean cargo cache to reduce layer size
RUN rm -rf /usr/local/cargo/registry/*

# Stage 2: Final runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y git fzf ripgrep fd-find jq less && \
    ln -s /usr/bin/fdfind /usr/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# Copy installed binaries from builder
COPY --from=builder /usr/bin/bat /usr/bin/
COPY --from=builder /usr/local/bin/bat* /usr/local/bin/
COPY --from=builder /usr/local/cargo/bin/cargo-audit /usr/local/cargo/bin/cross /usr/local/bin/

# Create user
RUN groupadd -r user && useradd -r -g user user

# Set up bat configuration
RUN mkdir -p /home/user/.config/bat && \
    echo -e '--theme="TwoDark"\n--style="numbers,changes,header"\n--italic-text=always\n--pager="less -RF"' > /home/user/.config/bat/config && \
    mkdir -p /etc/bat && \
    cp /home/user/.config/bat/config /etc/bat/config

# Set environment variables
RUN echo 'export BAT_PAGER="less -RFK"' >> /home/user/.bashrc && \
    echo 'export MANPAGER="sh -c '\''col -bx | bat -l man -p'\''"' >> /home/user/.bashrc

# Copy repository content
COPY . /app
WORKDIR /app

# Final setup steps
USER user
RUN bat cache --build

# Default command
CMD ["/bin/bash"]