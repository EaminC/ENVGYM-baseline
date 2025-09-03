FROM ubuntu:22.04 AS base
ARG DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    make \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Configure Rust toolchain
RUN rustup default stable \
    && rustup target add x86_64-unknown-linux-gnu \
    && rustup target add x86_64-unknown-linux-musl \
    && rustup component add rustfmt

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . .

# Build project
RUN cargo build --release --target x86_64-unknown-linux-gnu

# Final stage
FROM ubuntu:22.04
COPY --from=base /workspace/target/x86_64-unknown-linux-gnu/release/fd /usr/local/bin/fd

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set entrypoint
ENTRYPOINT ["/bin/bash"]