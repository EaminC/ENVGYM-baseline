FROM rust:1.80-bookworm

# Update package lists
RUN apt-get update || true

# Install core build tools
RUN apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    pkg-config \
    build-essential \
    gcc \
    g++ \
    clang \
    libc6-dev \
    gcc-multilib \
    || true

# Install graphics libraries
RUN apt-get install -y --no-install-recommends \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libx11-dev \
    libxi-dev \
    libxcursor-dev \
    libxrandr-dev \
    libxxf86vm-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    || true

# Install development tools
RUN apt-get install -y --no-install-recommends \
    valgrind \
    linux-perf \
    ctags \
    jq \
    musl-tools \
    nodejs \
    npm \
    || true

# Clean up
RUN rm -rf /var/lib/apt/lists/*

# Install Rust components and tools
RUN rustup component add rustfmt rust-analyzer && \
    rustup target add wasm32-unknown-unknown && \
    rustup target add wasm32-wasi && \
    rustup target add i686-unknown-linux-gnu

# Install cargo tools
RUN cargo install wasm-pack || true
RUN cargo install wasm-bindgen-cli --version 0.2.100 || true
RUN cargo install cargo-workspaces || true
RUN cargo install cargo-outdated || true
RUN cargo install cargo-audit || true
RUN cargo install cargo-release || true
RUN cargo install mdbook || true
RUN cargo install cargo-vendor || true
RUN cargo install sccache || true

# Install wasmtime
RUN curl https://wasmtime.dev/install.sh -sSf | bash && \
    mv $HOME/.wasmtime/bin/wasmtime /usr/local/bin/ || true

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh || true

# Clean up again
RUN rm -rf /var/lib/apt/lists/*

# Set up sccache
ENV RUSTC_WRAPPER=sccache
ENV SCCACHE_DIR=/tmp/sccache

# Create workspace directory
WORKDIR /workspace

# Clone the repository
RUN git clone https://github.com/rayon-rs/rayon.git .

# Set up cargo config
RUN mkdir -p .cargo && \
    echo '[target.wasm32-unknown-unknown]\nrunner = "wasm-bindgen-test-runner"' > .cargo/config.toml

# Pre-build dependencies to cache them
RUN cargo fetch || true

# Set environment variables
ENV RUST_BACKTRACE=1
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

# Default to bash when container starts
CMD ["/bin/bash"]