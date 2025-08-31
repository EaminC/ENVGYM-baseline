FROM rust:latest

# Install system dependencies if needed
RUN apt-get update && apt-get install -y build-essential pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /clap

# Copy Cargo manifests first to leverage Docker cache
COPY Cargo.toml Cargo.lock ./
COPY clap_bench/Cargo.toml ./clap_bench/
COPY clap_builder/Cargo.toml ./clap_builder/
COPY clap_derive/Cargo.toml ./clap_derive/
COPY clap_lex/Cargo.toml ./clap_lex/
COPY clap_complete/Cargo.toml ./clap_complete/
COPY clap_complete_nushell/Cargo.toml ./clap_complete_nushell/
COPY clap_mangen/Cargo.toml ./clap_mangen/

# Copy source files
COPY src ./src
COPY clap_bench ./clap_bench
COPY clap_builder ./clap_builder
COPY clap_derive ./clap_derive
COPY clap_lex ./clap_lex
COPY clap_complete ./clap_complete
COPY clap_complete_nushell ./clap_complete_nushell
COPY clap_mangen ./clap_mangen
COPY examples ./examples
COPY tests ./tests

# Build the workspace (release build)
RUN cargo build --workspace --release

# Start with bash prompt
CMD ["/bin/bash"]
