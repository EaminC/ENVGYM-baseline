# Use a stable Ubuntu LTS base image for compatibility and long-term support.
FROM ubuntu:22.04

# Set environment variables to enable non-interactive installation of packages.
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Step 1: Install system-level prerequisites, development tools, and shells.
# This includes build tools, version control, Python, and shells for the test suite.
# ca-certificates is required for secure downloads (e.g., with curl).
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    make \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    # Recommended tools
    ripgrep \
    # Shells for integration tests
    fish \
    zsh \
    elvish \
    nushell \
    && \
    # Clean up apt cache to reduce final image size.
    rm -rf /var/lib/apt/lists/*

# Install Rust via rustup, the official toolchain manager.
# The '-y' flag automates the installation process.
# '--no-modify-path' prevents rustup from altering shell profiles directly;
# we will manage the PATH explicitly with an ENV instruction for container consistency.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Add the Cargo bin directory to the system's PATH. This makes Rust tools
# like `cargo`, `rustc`, and `rustup` available in subsequent layers and
# in the final container's shell. We also pre-emptively add the path for
# the `bencher` CLI, which will be installed later.
ENV PATH="/root/.cargo/bin:/root/.bencher/bin:${PATH}"

# Set the primary working directory for the project.
WORKDIR /app

# Step 2: Get the source code by cloning the official repository.
# Cloning into the current directory (`.`) populates /app.
RUN git clone https://github.com/clap-rs/clap.git .

# Step 1 (continued): Install all required Rust toolchains and components.
# This multi-step command ensures a consistent and complete Rust environment
# as defined by the project's contribution guidelines and CI configuration.
RUN \
    # First, install the specific toolchain from rust-toolchain.toml for CI reproducibility.
    # The file itself will ensure cargo uses this version within the directory.
    PINNED_VERSION=$(grep '^version = ' rust-toolchain.toml | cut -d '"' -f 2) && \
    rustup toolchain install "$PINNED_VERSION" --component clippy --component rustfmt && \
    \
    # Then, install standard stable, beta, and nightly toolchains for general use.
    rustup toolchain install stable beta nightly && \
    \
    # Set the latest stable toolchain as the default for the container's global environment.
    rustup default stable && \
    \
    # Ensure the default toolchain also has standard components.
    rustup component add clippy rustfmt && \
    \
    # Install WebAssembly targets required for Wasm compatibility checks.
    rustup target add wasm32-unknown-unknown wasm32-wasip2

# Step 1 (continued): Install Python and Cargo-based development and CI tools.
RUN \
    # Install the pre-commit framework using pip.
    pip install pre-commit && \
    # Install the Bencher CLI for performance benchmarking.
    curl -s https://bencher.dev/install.sh | sh && \
    # Install the suite of Cargo-based tools for linting, auditing, and release management.
    cargo install cargo-deny cargo-audit cargo-hack cargo-release typos-cli committed

# Step 3: Install the Git pre-commit hooks as defined in .pre-commit-config.yaml.
# This automates code quality checks before commits are made.
RUN pre-commit install --install-hooks

# Step 4: Pre-build the entire workspace to download and compile all dependencies.
# This command (`make build-default` runs `cargo test --no-run`) leverages Docker's
# layer caching, significantly speeding up subsequent builds and tests for the user
# by ensuring all dependencies are already compiled.
RUN make build-default

# Set the final working directory again to ensure it's the active directory
# when the container starts.
WORKDIR /app

# Provide an interactive bash shell as the entrypoint for the container.
# The user will be placed in the /app directory with the full development
# environment configured and ready to use.
CMD ["/bin/bash"]