FROM rust:1.80-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libssl-dev \
    pkg-config \
    libsystemd-dev \
    ca-certificates \
    curl \
    wget \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchains
RUN rustup toolchain install stable --component rust-src rustfmt clippy
RUN rustup toolchain install nightly && \
    rustup component add --toolchain nightly rustfmt clippy || true && \
    rustup component add --toolchain nightly rust-src || true
RUN rustup toolchain install 1.81.0
RUN rustup component add --toolchain 1.81.0 rust-src rustfmt clippy
RUN rustup target add wasm32-unknown-unknown --toolchain 1.81.0
RUN rustup default stable

# Install cargo tools
RUN cargo install cargo-edit \
    cargo-watch \
    cargo-workspaces \
    cargo-audit \
    cargo-nextest \
    cargo-hack \
    cargo-minimal-versions \
    wasm-pack \
    wasm-bindgen-cli \
    inferno

# Install Netlify CLI
RUN npm install -g netlify-cli

# Create workspace directory
WORKDIR /workspace

# Copy repository files
COPY . .

# Set up git safe directory
RUN git config --global --add safe.directory /workspace

# Build the workspace to ensure all dependencies are fetched
RUN cargo build --all-features --workspace
RUN cargo build --all-features --workspace --release

# Set environment variables
ENV RUST_BACKTRACE=1
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# Default to bash
CMD ["/bin/bash"]