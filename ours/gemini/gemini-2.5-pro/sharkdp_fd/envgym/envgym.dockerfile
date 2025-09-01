# Base Image: Use a stable Debian image as it's a common and reliable choice for builds.
FROM debian:stable-slim

# Set platform argument for clarity, matching the plan's x86_64 architecture.
ARG TARGETPLATFORM=linux/amd64

# Set environment variables to avoid interactive prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Set standard environment variables for a system-wide Rust installation.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:${PATH} \
    RUST_VERSION=stable

# 1. Install System Prerequisites: C compiler, make, git, and other essential tools.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    make \
    git \
    curl \
    ca-certificates \
    # Clean up apt cache to reduce image size.
    && rm -rf /var/lib/apt/lists/*

# 2. Install Rust Toolchain and Components: Install rustup, the stable toolchain, rustfmt, and clippy.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION} --profile default && \
    rustup component add rustfmt && \
    rustup component add clippy

# 4. Create and set the working directory as specified in the plan.
WORKDIR /home/cc/EnvGym/data/sharkdp_fd

# 3. Prepare Project Source Code: Clone the repository into the working directory.
RUN git clone https://github.com/sharkdp/fd.git .

# To optimize Docker layer caching, first build only the dependencies.
# This layer will only be rebuilt if Cargo.toml or Cargo.lock changes.
RUN cargo build --release --locked && rm -rf target/

# 5. Run Code Quality Checks as specified in the plan.
RUN cargo fmt -- --check
RUN cargo clippy --all-targets --all-features -- -Dwarnings

# 6. Fetch Dependencies and Run Tests.
RUN cargo test --locked

# 7. Build the Executable (Native Release Version).
RUN cargo build --release --locked

# 9. Generate Supporting Files (Shell completions).
RUN make completions

# 11. Install the executable, man page, and completions system-wide within the container.
RUN make install

# Final Step: Configure the container to start a bash shell.
# This places the user in the project's root directory (/home/cc/EnvGym/data/sharkdp_fd)
# with the full toolchain and source code available for interaction.
CMD ["/bin/bash"]